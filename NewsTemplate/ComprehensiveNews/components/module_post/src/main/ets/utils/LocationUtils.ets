import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[LocationUtils]';

/**
 * 位置工具类
 */
export class LocationUtils {
  /**
   * 获取当前所在城市信息
   * @returns
   */
  static async getCurrentCityInfo(): Promise<site.City> {
    try {
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 1000,
      };
      const location = await geoLocationManager.getCurrentLocation(request);

      const reverseGeocodeParams: site.ReverseGeocodeParams = {
        location: location,
        language: 'zh_CN',
      };
      const reverseGeocodeResult = await site.reverseGeocode(reverseGeocodeParams);
      UtilLog.info(TAG, 'reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return reverseGeocodeResult.addressComponent.city ?? { cityName: '' };
    } catch (e) {
      UtilLog.error(TAG, 'getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      // todo 获取异常时，mock返回【南京】
      return { cityName: '南京' };
    }
  }
}