import { abilityAccessCtrl, common, Permissions, bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ContextUtil } from './ContextUtil';

const TAG: string = '[PermissionUtil]';

enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  /**
   * 获取推送授权
   */
  public static requestNotificationPermission(callback?: () => void) {
    if (!ContextUtil.globalContext) {
      Logger.error(TAG, 'cannot get context');
      return;
    }
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      Logger.info(TAG, 'isNotificationEnabled success, data: ' + JSON.stringify(data));
      if (!data) {
        notificationManager.requestEnableNotification(ContextUtil.globalContext as common.UIAbilityContext).then(() => {
          Logger.info(TAG, `requestEnableNotification success`);
          callback?.();
        }).catch((err: BusinessError) => {
          if (1600004 === err.code) {
            Logger.error(TAG,
              `requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
          } else {
            Logger.error(TAG, `requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      } else {
        callback?.();
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
    });
  }

  /**
   * @param permissions 待申请的权限列表
   * @param secondary 是否支持二次授权
   * @returns
   */
  public static async requestPermissions(permissions: Permissions[], secondary: boolean = false) {
    const needAuthorized: Permissions[] = [];
    for (let permission of permissions) {
      const isGranted: boolean = await PermissionUtil._checkPermissions(permission);
      if (!isGranted) {
        needAuthorized.push(permission);
      }
    }
    if (!needAuthorized.length) {
      return Promise.resolve(true);
    }
    if (!ContextUtil.globalContext) {
      return Promise.reject();
    }
    // 向用户申请授权
    return await PermissionUtil._atManager
      .requestPermissionsFromUser(ContextUtil.globalContext, needAuthorized)
      .then((data) => {
        let grantStatus: number[] = data.authResults;
        let length: number = grantStatus.length;
        let permissive = true;
        for (let i = 0; i < length; i++) {
          if (grantStatus[i] === PermissionStatus.GRANTED) {
            Logger.info(TAG, 'request permission success::' + needAuthorized[i]);
            break;
          } else if (secondary && grantStatus[i] === PermissionStatus.DENIED) {
            PermissionUtil._requestPermissionsOnSetting(needAuthorized[i]);
            break;
          } else {
            permissive = false;
            Logger.info(TAG, 'request permission failed:: user denied');
            break;
          }
        }
        if (permissive) {
          return Promise.resolve(true);
        }
        return Promise.reject();
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
  }

  private static async _checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil._checkAccessToken(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }
    return false;
  }

  /** 校验应用是否被授予权限 */
  private static async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoForSelfSync(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION,
      );
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

  /** 用户首次拒绝后二次申请授权 */
  private static async _requestPermissionsOnSetting(permissions: Permissions) {
    PermissionUtil._atManager
      .requestPermissionOnSetting(ContextUtil.globalContext, [permissions])
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        Logger.info(TAG, 'request permission on setting success::' + JSON.stringify(data));
      })
      .catch((err: BusinessError) => {
        Logger.error(
          TAG,
          `Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`,
        );
      });
  }
}
