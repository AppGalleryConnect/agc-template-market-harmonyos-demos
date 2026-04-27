import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { PermissionStatus } from '../model/Index';


export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  public static async requestPermissions(permissions: Permissions[], context: Context) {
    const needAuthorized: Permissions[] = [];
    let permissive = true;
    for (let permission of permissions) {
      const isGranted: boolean = await PermissionUtil._checkPermissions(permission);
      if (!isGranted) {
        needAuthorized.push(permission);
      }
    }
    if (!needAuthorized.length) {
      return permissive;
    }
    // 向用户申请授权
    const data = await PermissionUtil._atManager.requestPermissionsFromUser(context, needAuthorized);
    let grantStatus: number[] = data.authResults;
    let length: number = grantStatus.length;

    const needAuthorizedAgain: Permissions[] = [];
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === PermissionStatus.GRANTED) {
        Logger.info('request permission success::' + needAuthorized[i]);
      } else if (grantStatus[i] === PermissionStatus.DENIED) {
        needAuthorizedAgain.push(needAuthorized[i]);
      } else {
        permissive = false;
        Logger.info('request permission failed:: user denied');
      }
    }

    PermissionUtil._requestPermissionsOnSetting(needAuthorizedAgain, context);
    return permissive;
  }

  public static async _checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil._checkAccessToken(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }
    return false;
  }

  // 用户首次拒绝后二次申请授权
  private static async _requestPermissionsOnSetting(permissions: Permissions[], context: Context) {
    PermissionUtil._atManager.requestPermissionOnSetting(context, permissions)
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        Logger.info('request permission on setting success:' + JSON.stringify(data));
      })
      .catch((err: BusinessError) => {
        Logger.error(`Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`);
      });
  }


  // 校验应用是否被授予权限
  private static async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      if (appInfo) {
        tokenId = appInfo.accessTokenId;
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await PermissionUtil._atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }
}