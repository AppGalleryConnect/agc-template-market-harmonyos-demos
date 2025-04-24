import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { WindowUtil } from './WindowUtil';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

export interface LocationResultData {
  result: LocationStatus;
  gcj02LatLng?: mapCommon.LatLng;
}

export enum LocationStatus {
  SUCCESS = 'SUCCESS',
  PERMISSION_DENIED = 'PERMISSION_DENIED', // 权限获取失败
  UNKNOWN_ERROR = 'UNKNOWN_ERROR', // 获取位置时发生未知异常
}

const TAG: string = '[LocationUtil]';

export class LocationUtil {
  private static cache: mapCommon.LatLng | undefined = undefined;

  public static calculateDistance(fromLatLng: mapCommon.LatLng, toLatLng: mapCommon.LatLng): number {
    return map.calculateDistance(fromLatLng, toLatLng);
  }

  public static parseLatLng(input: string): mapCommon.LatLng | null {
    const coordinates = input.split(',');
    if (coordinates.length === 2) {
      const longitude = parseFloat(coordinates[0]);
      const latitude = parseFloat(coordinates[1]);
      if (!isNaN(longitude) && !isNaN(latitude)) {
        return {
          latitude: latitude,
          longitude: longitude,
        };
      }
    }
    return null;
  }

  public static async getCachedGCJ02Location(): Promise<LocationResultData> {
    if (LocationUtil.cache !== undefined) {
      return { result: LocationStatus.SUCCESS, gcj02LatLng: LocationUtil.cache };
    }
    const context = WindowUtil.context as common.UIAbilityContext;
    if (!context) {
      Logger.error(TAG, 'get context failed');
      return { result: LocationStatus.UNKNOWN_ERROR };
    }
    return await LocationUtil.getGCJ02Location(context);
  }

  public static async getGCJ02Location(context: common.UIAbilityContext): Promise<LocationResultData> {
    const hasPermission = await LocationUtil.requestLocationPermissions(context);

    if (!hasPermission) {
      return { result: LocationStatus.PERMISSION_DENIED };
    }

    try {
      const gcj02LatLng = await LocationUtil.fetchCurrentLocation();
      LocationUtil.cache = gcj02LatLng;
      return { result: LocationStatus.SUCCESS, gcj02LatLng: gcj02LatLng };
    } catch (error) {
      return { result: LocationStatus.UNKNOWN_ERROR };
    }
  }

  private static async fetchCurrentLocation(): Promise<mapCommon.LatLng> {
    const locationRequest: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      timeoutMs: 10000,
    };
    return new Promise((resolve, reject) => {
      try {
        geoLocationManager.getCurrentLocation(
          locationRequest,
          (error: BusinessError, location: geoLocationManager.Location) => {
            if (error) {
              reject(error);
            } else {
              resolve(LocationUtil.convertLocationToGCJ02(location));
            }
          },
        );
      } catch (e) {
        reject(new Error('geoLocationManager.getCurrentLocation 自身调用异常: ' + e.message));
      }
    });
  }

  private static convertLocationToGCJ02(location: geoLocationManager.Location): mapCommon.LatLng {
    const wgs84LatLng: mapCommon.LatLng = {
      latitude: location.latitude,
      longitude: location.longitude,
    };
    return map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84LatLng);
  }

  private static async requestLocationPermissions(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const accessCtrlManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const accessTokenId: number = await LocationUtil.getAccessTokenId();
      const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
      for (let permission of permissions) {
        if (
          accessCtrlManager.checkAccessTokenSync(accessTokenId, permission) ===
          abilityAccessCtrl.GrantStatus.PERMISSION_DENIED
        ) {
          const result: PermissionRequestResult = await accessCtrlManager.requestPermissionsFromUser(
            context,
            permissions,
          );
          return result.authResults.every((auth) => auth === 0);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  private static async getAccessTokenId(): Promise<number> {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
    );
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    return appInfo.accessTokenId;
  }
}
