import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { Logger } from './Logger';


const TAG: string = '[PermissionUtil]';

enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  private static _context: Context;

  public static async requestPermissions(
    permissions: Permissions[],
    success?: Callback<void>,
    failed?: Callback<void>) {
    const needAuthorized: Permissions[] = [];
    for (let permission of permissions) {
      const isGranted: boolean = await PermissionUtil.checkPermissions(permission);
      if (!isGranted) {
        needAuthorized.push(permission);
      }
    }
    if (!needAuthorized.length) {
      success?.();
      return;
    }
    if (!PermissionUtil._context) {
      PermissionUtil._context = getContext() as common.UIAbilityContext;
    }
    // 向用户申请授权
    PermissionUtil._atManager.requestPermissionsFromUser(PermissionUtil._context, needAuthorized).then((data) => {
      let grantStatus: number[] = data.authResults;
      let length: number = grantStatus.length;
      let permissive = true;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === PermissionStatus.GRANTED) {
          Logger.info(TAG, 'request permission success::' + needAuthorized[i]);
          return;
        } else if (grantStatus[i] === PermissionStatus.DENIED) {
          PermissionUtil._requestPermissionsOnSetting(needAuthorized[i], success, failed);
          return;
        } else {
          permissive = false;
          failed?.();
          return;
        }
      }
      if (permissive) {
        success?.();
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    });
  }

  // 用户首次拒绝后二次申请授权
  private static async _requestPermissionsOnSetting(
    permissions: Permissions,
    success?: Callback<void>,
    failed?: Callback<void>) {
    PermissionUtil._atManager.requestPermissionOnSetting(PermissionUtil._context, [permissions])
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        const hasDenied = data.some((status) => status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED);
        if (hasDenied) {
          failed?.();
        } else {
          success?.();
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG,
          `Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`);
      });
  }

  public static async checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil._checkAccessToken(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }
    return false;
  }

  // 校验应用是否被授予权限
  private static async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await PermissionUtil._atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }
}