import { sceneMap } from '@kit.MapKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { geoLocationManager } from '@kit.LocationKit';

const TAG = 'ChooseLocationUtil';

export class ChooseLocationUtil {


  static chooseLocation(context: common.UIAbilityContext): Promise<sceneMap.LocationChoosingResult> {
    ChooseLocationUtil.requestLocationPermissionsFromUser(context);
    return new Promise(async (resolve, reject) => {
      let currentLocation = await ChooseLocationUtil.getCurrentLocation();
      try {
        let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
          // 地图中心点坐标
          location: { latitude: currentLocation.latitude, longitude: currentLocation.longitude },
          language: 'zh',
          // 展示搜索控件
          searchEnabled: true,
          // 展示附近POI
          showNearbyPoi: true
        };
        // 拉起地点选取页
        sceneMap.chooseLocation(context, locationChoosingOptions).then((data) => {
          hilog.info(0x0000, TAG, '%{public}s',
            'chooseLocation Succeeded in choosing location. ' + JSON.stringify(data));
          resolve(data);
        }).catch((err: BusinessError) => {
          hilog.info(0x0000, TAG, '%{public}s', 'chooseLocation Failed to choose location. ' + JSON.stringify(err));
          reject(err);
        });
      } catch (err) {
        hilog.info(0x0000, TAG, '%{public}s', 'chooseLocation err. ' + JSON.stringify(err));
        reject(err);
      }
    });
  }

  static async getCurrentLocation(): Promise<geoLocationManager.Location> {
    return new Promise((resolve) => {
      let currentLocation: geoLocationManager.Location = {
        latitude: 31.8698571539735,
        longitude: 118.82523154589367,
        altitude: 0,
        accuracy: 0,
        speed: 0,
        timeStamp: 0,
        direction: 0,
        timeSinceBoot: 0
      }

      try {
        let request: geoLocationManager.SingleLocationRequest = {
          'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
          'locatingTimeoutMs': 10000
        }

        geoLocationManager.getCurrentLocation(request).then((data) => {
          hilog.info(0x0000, TAG, '%{public}s', 'get current location success. ' + JSON.stringify(data));
          resolve(data);
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, '%{public}s', 'get current location fail. ' + JSON.stringify(err));
          resolve(currentLocation);
        });
      } catch (err) {
        hilog.error(0x0000, TAG, '%{public}s', 'get current location err. ' + JSON.stringify(err));
        resolve(currentLocation);
      }
    });
  }

  /**
   * 请求位置权限
   */
  static async requestLocationPermissionsFromUser(context: common.UIAbilityContext) {
    try {
      let atManager = abilityAccessCtrl.createAtManager();
      const permissions: Array<Permissions> = [
        'ohos.permission.LOCATION',
        'ohos.permission.APPROXIMATELY_LOCATION'
      ];
      const data = await atManager.requestPermissionsFromUser(context, permissions);
      if (data.authResults.every(result => result === 0)) {
        hilog.info(0x0000, TAG, '%{public}s', 'permission authorized');
      } else {
        hilog.error(0x0000, TAG, '%{public}s', 'user refuse');
      }
    } catch (err) {
      hilog.error(0x0000, TAG, '%{public}s', 'request fail err: ' + JSON.stringify(err));
    }
  }
}