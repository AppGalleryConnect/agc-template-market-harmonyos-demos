import { geoLocationManager } from '@kit.LocationKit';

export class City {
  locality: string = '';
  placeName: string = '';
}

/**
 * 获取当前所在城市位置
 * @returns
 */
export const getCurrentCityInfo = async (): Promise<City | undefined> => {
  try {
    const requestInfo: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'maxAccuracy': 0
    };
    const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);
    const reverseRequest: geoLocationManager.ReverseGeoCodeRequest = {
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
      maxItems: 1
    };
    const cityData = await geoLocationManager.getAddressesFromLocation(reverseRequest)
    return {
      locality: cityData[0].locality || '未知城市',
      placeName: cityData[0].placeName || '未知地址'
    }
  } catch (e) {
    return undefined;
  }
}
