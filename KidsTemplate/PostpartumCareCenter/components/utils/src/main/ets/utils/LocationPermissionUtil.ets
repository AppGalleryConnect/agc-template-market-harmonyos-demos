import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import { geoLocationManager } from '@kit.LocationKit';


const TAG: string = '[testTagLocationPermissionUtil]';

enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

export class LocationPermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  private static _context: Context;

  public static async requestGlobalLocationSwitch(callback?: Callback<void>) {
    if (!LocationPermissionUtil._context) {
      LocationPermissionUtil._context = getContext() as common.UIAbilityContext;
    }
    if (!geoLocationManager.isLocationEnabled()) {
      LocationPermissionUtil._atManager.requestGlobalSwitch(LocationPermissionUtil._context,
        abilityAccessCtrl.SwitchType.LOCATION).then((data: boolean) => {
        if (data) {
          callback?.();
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'data:' + JSON.stringify(err));
      });
    } else {
      callback?.();
    }
  }

  public static async requestLocationPermissions(permissions: Permissions[], callback?: Callback<void>) {
    if (!LocationPermissionUtil._context) {
      LocationPermissionUtil._context = getContext() as common.UIAbilityContext;
    }

    try {
      LocationPermissionUtil._requestPermissions(LocationPermissionUtil._context, permissions, callback);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `RequestPermissions failed. Code is ${err.code}, message is ${err.message}`);
    }
  }

  // 是否已获取了所有权限
  public static async hasAllPermissions(permissions: Permissions[], callbackOfTrue: Callback<void>,
    callbackOfFalse: Callback<void>) {
    // 判断是否已经获取了所有权限
    let hasPermission = true;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      Logger.info(TAG, 'getBundleInfoForSelfSync successfully: %{public}s', JSON.stringify(bundleInfo));
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG,
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    if (!LocationPermissionUtil._context) {
      LocationPermissionUtil._context = getContext() as common.UIAbilityContext;
    }

    try {
      for (let permission of permissions) {
        if (LocationPermissionUtil._atManager.checkAccessTokenSync(tokenId, permission) !==
        abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          hasPermission = false;
        }
      }
      if (hasPermission) {
        callbackOfTrue?.();
      } else {
        callbackOfFalse?.();
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private static async _requestPermissions(context: Context, needAuthorized: Permissions[], callback?: Callback<void>) {
    // 向用户申请授权
    try {
      LocationPermissionUtil._atManager.requestPermissionsFromUser(context, needAuthorized).then((data) => {
        if (data.authResults[0] === PermissionStatus.DENIED ||
          data.authResults[1] === PermissionStatus.DENIED) { // 存在权限没有被授予
          // 用户看过对话弹框，并且用户拒绝了权限,不执行callback
          if (data.dialogShownResults && (data.dialogShownResults[0] || data.dialogShownResults[1])) {
            // callback?.();
          } else { // 用户没有看到权限对话弹框，则打开权限设置
            LocationPermissionUtil._requestPermissionsOnSetting(needAuthorized, callback);
            return;
          }
        } else {
          if (data.authResults[0] === PermissionStatus.GRANTED) {
            callback?.();
          } else {
            return;
          }
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
    } catch (err) {
      Logger.error(TAG, '_requestPermissions err:' + JSON.stringify(err));
    }
  }

  // 用户首次拒绝后二次申请授权
  private static async _requestPermissionsOnSetting(permissions: Permissions[], callback?: Callback<void>) {
    LocationPermissionUtil._atManager.requestPermissionOnSetting(LocationPermissionUtil._context, permissions)
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        if (data[0] === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED &&
          data[1] === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
          return;
        } else {
          callback?.();
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`);
      });
  }
}