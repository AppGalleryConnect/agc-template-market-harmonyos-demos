import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constants/CommonContants';
import { Logger } from './Logger';

const TAG: string = '[testTagLocateUtil]';

export class LocateUtil {
  public static userLatitude: number | null = null;
  public static userLongitude: number | null = null;

  public static getDistance(destLatitude: number, destLongitude: number): string | null {
    if (LocateUtil.userLatitude && LocateUtil.userLongitude) {
      return LocateUtil.calculateDistance(destLatitude, destLongitude, LocateUtil.userLatitude,
        LocateUtil.userLongitude);
    }
    Logger.debug(TAG, 'getDistance failed');
    return null;
  }

  /**
   * Get cache location information
   */
  public static getPreLocationPosition() {
    try {
      let location = geoLocationManager.getLastLocation();
      LocateUtil.userLatitude = location.latitude;
      LocateUtil.userLongitude = location.longitude;
      Logger.debug(TAG,
        `getPreLocationPosition success, latitude: ${location.latitude}, longitude: ${location.longitude}`);
    } catch (err) {
      Logger.error(TAG, `getPreLocationPosition failed, code: ${err.code}, message: ${err.message}`);
      LocateUtil.locationFailedAlert(err.code);
    }
  }

  /**
   * Get current location information
   */
  public static getLocationPosition(callback?: Callback<void>) {
    let request: geoLocationManager.SingleLocationRequest = {
      locatingPriority: CommonConstants.PRIORITY_LOCATING_SPEED,
      locatingTimeoutMs: CommonConstants.LOCATING_TIMEOUT_MS,
    };
    geoLocationManager.getCurrentLocation(request).then((location: geoLocationManager.Location) => {
      LocateUtil.userLatitude = location.latitude;
      LocateUtil.userLongitude = location.longitude;
      callback?.();
      Logger.debug(TAG,
        `getCurrentLocation success, latitude: ${location.latitude}, longitude: ${location.longitude}`);
    })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `getCurrentLocationPosition failed, code: ${err.code}, message: ${err.message}`);
        LocateUtil.locationFailedAlert(err.code);
      });
  }


  public static locationFailedAlert(errCode: number) {
    if (errCode === CommonConstants.LOCATION_SWITCH_OFF) {
      promptAction.showToast({
        message: $r('app.string.location_switch'),
        duration: 2000,
      });
    } else if (errCode === CommonConstants.LOCATION_FAILED) {
      promptAction.showToast({
        message: $r('app.string.internet_switch'),
        duration: 2000,
      });
    } else if (errCode === CommonConstants.REVERSE_GEOCODING_FAILED) {
      promptAction.showToast({
        message: $r('app.string.internet_switch'),
        duration: 2000,
      });
    } else if (errCode === CommonConstants.WIFI_BLUETOOTH_OFF) {
      promptAction.showToast({
        message: $r('app.string.wifi_bluetooth_switch'),
        duration: 2000,
      });
    }
  }

  public static calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number) {
    const R = 6371; // 地球半径，单位为公里
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    return distance.toFixed(1); // 单位为公里
  }
}