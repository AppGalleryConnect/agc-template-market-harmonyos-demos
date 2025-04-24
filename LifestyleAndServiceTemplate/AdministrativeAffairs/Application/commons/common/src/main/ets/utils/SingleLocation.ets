import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { site } from '@kit.MapKit';

export function getCurrentLocation(): Promise<ESObject> {
  let request: geoLocationManager.SingleLocationRequest = {
    locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
    locatingTimeoutMs: 10000
  };
  return new Promise((resolve, reject) => {
    geoLocationManager.getCurrentLocation(request).then(async (location: geoLocationManager.Location) => {
      let params: site.ReverseGeocodeParams = {
        // 位置经纬度
        location: {
          latitude: location.latitude,
          longitude: location.longitude
        },
        language: 'cn',
        radius: 200
      };
      const result = await site.reverseGeocode(params);
      resolve(result.addressComponent.adminLevel2)
    }).catch((err: BusinessError) => {
      reject('failed' + err)
    });
  })
}