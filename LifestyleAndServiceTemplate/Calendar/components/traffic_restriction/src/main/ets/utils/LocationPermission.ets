import { abilityAccessCtrl, common, PermissionRequestResult, Want } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[PermissionRequestUtils]'

export class PermissionRequestUtils {
  static context: UIContext

  setContext(context: UIContext) {
    PermissionRequestUtils.context = context
  }

  public async locationPermissionRequest(): Promise<string> {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let result: PermissionRequestResult =
        await atManager.requestPermissionsFromUser(PermissionRequestUtils.context.getHostContext()!, [
          'ohos.permission.APPROXIMATELY_LOCATION',
          'ohos.permission.LOCATION'])
      if (result.authResults[0] !== 0 || result.authResults[1] !== 0) {
        return Promise.resolve('failed');
      } else {
        return Promise.resolve('success');
      }
    } catch (err) {
      return Promise.reject('failed');
    }
  }

  public getCurrentLocation(): Promise<ESObject> {
    let request: geoLocationManager.SingleLocationRequest = {
      locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
      locatingTimeoutMs: 10000,
    };
    return new Promise((resolve, reject) => {
      geoLocationManager.getCurrentLocation(request).then(async (location: geoLocationManager.Location) => {
        let params: site.ReverseGeocodeParams = {
          // 位置经纬度
          location: {
            latitude: location.latitude,
            longitude: location.longitude,
          },
          language: 'cn',
          radius: 200,
        };
        try {
          const result = await site.reverseGeocode(params);
          resolve(result.addressComponent.adminLevel2)
        } catch (e) {
          reject('failed' + e)
          UtilLog.error('reverseGeocode error' + JSON.stringify(e))
        }
      }).catch((err: BusinessError) => {
        reject('failed' + err)
      });
    })
  }
}

export function openPermissionsInSystemSettings(context: common.UIAbilityContext): void {
  let bundleFlags =
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
  try {
    bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
      let want: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
          settingsParamBundleName: data.name,
        },
      };
      context.startAbility(want)
      UtilLog.info(TAG, 'getBundleInfoForSelf successfully. Data: %{public}s', JSON.stringify(data));
    }).catch((err: BusinessError) => {
      UtilLog.info(TAG, 'getBundleInfoForSelf failed. Cause: %{public}s', err.message);
    });
  } catch (err) {
    let message = (err as BusinessError).message;
    UtilLog.info(TAG, 'getBundleInfoForSelf failed: %{public}s', message);
  }
}