import {
  abilityAccessCtrl,
  bundleManager,
  common,
  PermissionRequestResult,
  Permissions,
} from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { IPosition } from '../types/Types';

export class CommonUtil {
  public static debounce<T>(func: (params: T) => void, delay: number) {
    let timer: number = -1;
    return (params: T) => {
      clearTimeout(timer);
      timer = setTimeout(() => {
        func(params);
      }, delay);
    };
  }
}

/**
 * 日志类
 */
export class Logger {
  private static _domain: number = 0xFF00;
  private static _prefix: string = '[CityManage]';
  private static _format: string = '%{public}s';

  public static info(...args: string[]): void {
    hilog.info(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(Logger._domain, Logger._prefix, Logger._format, args);
  }
}

/**
 * 工具类
 */
export class CityManager {
  public static applyLocationPermission(): Promise<IPosition> {
    return new Promise((resolve) => {
      SystemSceneUtils.applyLocationPermission().then((isGranted) => {
        if (isGranted) {
          SystemSceneUtils.getCurrentCityInfo().then((postion: IPosition) => {
            resolve(postion);
          });
        } else {
          resolve({ name: '北京', code: '110100' });
        }
      });
    });
  }
}


/**
 * 系统Utils
 */
export class SystemSceneUtils {
  static isApplyLocPermAgain: boolean = false;
  static context: common.UIAbilityContext | null = null

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  private static async _checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  public static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];
    const isGrantedAppLo = await SystemSceneUtils._checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info('already granted location and approximate location permissions')
      return true;
    }
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(SystemSceneUtils.context, permissions)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          return true;
        }
        // 二次向用户申请
        if (SystemSceneUtils.isApplyLocPermAgain) {
          try {
            const resp = await atManager.requestPermissionOnSetting(SystemSceneUtils.context, permissions);
            return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
          } catch (error) {
            const err: BusinessError = error as BusinessError;
            Logger.error(`Failed to request permission on setting. Code: ${err.code}, message: ${err.message}`);
            return false;
          }
        }
        SystemSceneUtils.isApplyLocPermAgain = true;
        return false;
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to requestPermissionsFromUser. Code: ${err.code}, message: ${err.message}`);
        return false;
      });
  }

  /**
   * 获取当前所在城市位置
   * @returns
   */
  public static async getCurrentCityInfo(): Promise<IPosition> {
    const position: IPosition = { name: '北京', code: '110100' };
    try {
      const requestInfo: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 1000,
      };
      const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);
      const reverseGeoCodeReq: site.ReverseGeocodeParams = {
        location: currentLocation,
        language: 'zh_CN',
      };
      const reverseGeocodeResult = await site.reverseGeocode(reverseGeoCodeReq);
      Logger.info('reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      if (reverseGeocodeResult.addressComponent.city?.cityName && reverseGeocodeResult.addressComponent.adminCode) {
        position.name = reverseGeocodeResult.addressComponent.city.cityName;
        position.code = reverseGeocodeResult.addressComponent.adminCode;
      }
      return position;
    } catch (e) {
      Logger.error('getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      return position;
    }
  }
}