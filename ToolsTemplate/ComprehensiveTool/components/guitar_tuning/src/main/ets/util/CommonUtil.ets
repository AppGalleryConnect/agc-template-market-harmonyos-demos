import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { PermissionStatus } from '../model/Index';

// 日志打印
export class MyLog {
  private static domain: number = 0xff00;
  private static tag: string = 'guitar_tuning';
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    UtilLog.info(MyLog.domain, MyLog.tag, MyLog.format, args);
  }

  public static error(...args: string[]): void {
    UtilLog.error(MyLog.domain, MyLog.tag, MyLog.format, args);
  }
}

// 权限工具
export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  public static async requestPermissions(permissions: Permissions[],ctx:Context) {
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
    const data = await PermissionUtil._atManager.requestPermissionsFromUser(ctx, needAuthorized);
    const grantStatus: number[] = data.authResults;
    const needAuthorizedAgain: Permissions[] = [];
    grantStatus.forEach((item, index) => {
      if (item === PermissionStatus.GRANTED) {
        MyLog.info('request permission success::' + needAuthorized[index]);
      } else if (item === PermissionStatus.DENIED) {
        needAuthorizedAgain.push(needAuthorized[index]);
      } else {
        permissive = false;
        MyLog.info('request permission failed:: user denied');
      }
    });
    PermissionUtil._requestPermissionsOnSetting(needAuthorizedAgain,ctx);
    return permissive;
  }

  // 用户首次拒绝后二次申请授权
  private static async _requestPermissionsOnSetting(permissions: Permissions[],ctx:Context) {
    PermissionUtil._atManager.requestPermissionOnSetting(ctx, permissions)
      .then((data: abilityAccessCtrl.GrantStatus[]) => {
        MyLog.info('request permission on setting success::' + JSON.stringify(data));
      })
      .catch((err: BusinessError) => {
        MyLog.error(`Failed to request permissions on setting from user. Code is ${err.code}, message is ${err.message}`);
      });
  }

  public  static async _checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil._checkAccessToken(permission);
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
  }

  // 校验应用是否被授予权限
  private static async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      const bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      if (appInfo) {
        tokenId = appInfo.accessTokenId;
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      MyLog.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await PermissionUtil._atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      MyLog.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }
}






