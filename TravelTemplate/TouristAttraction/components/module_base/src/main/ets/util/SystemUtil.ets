import { call } from '@kit.TelephonyKit';
import { common, Want } from '@kit.AbilityKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { map, mapCommon, site } from '@kit.MapKit';
import { UtilLog } from '@hw-agconnect/util-log';

export class SystemUtil {
  static routerToPetalMap(latitude: number, longitude: number, name: string, context: common.UIAbilityContext) {
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: 'com.atomicservice.5765880207855657821',
        destinationLatitude: latitude,
        destinationLongitude: longitude,
        destinationName: name,
      },
    };
    context.startAbility(petalMapWant);
  }

  static doRandBySync(len: number): string {
    let data: string = '';
    let rand = cryptoFramework.createRandom();
    try {
      let randData = rand.generateRandomSync(len);
      if (randData != null) {
        for (let i = 0; i < randData.data.length; i++) {
          data += randData.data[i];
        }
      } else {
        UtilLog.error(0xff00, 'SystemUtil', '[Sync]: get rand result fail!');
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      UtilLog.error(0xff00, 'SystemUtil', `do rand failed, ${e.code}, ${e.message}`);
    }
    return data;
  }

  static triggerForCall(uiContext: UIContext, phoneNo: string) {
    try {
      call.makeCall(phoneNo, (err) => {
        if (err) {
          UtilLog.error(0xff00, 'SystemUtil', 'make call failed ' + JSON.stringify(err));
          uiContext.getPromptAction().showToast({ message: '拨打号码失败' });
        } else {
          UtilLog.error(0xff00, 'SystemUtil', 'make call success');
        }
      });
    } catch (error) {
      UtilLog.error(0xff00, 'SystemUtil', 'make call error');
    }
  }

  static calDistance(parkingLot: number, parkingLat: number, latitude: number, longitude: number) {
    let fromLatLng: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude,
    };
    let toLatLng: mapCommon.LatLng = {
      latitude: parkingLat,
      longitude: parkingLot,
    };

    return map.calculateDistance(fromLatLng, toLatLng);
  }


  static getPoiListByText(latitude: number, longitude: number, poiText: string, range?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: latitude,
        longitude: longitude,
      },
      radius: range,
      language: 'zh_CN',
    };

    let result: Promise<site.SearchByTextResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'))
    })

    try {
      result = site.searchByText(params);
    } catch (e) {
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }
}