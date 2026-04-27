import { abilityAccessCtrl, bundleManager, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[PermissionUtils]';

/**
 * 权限工具类
 */
export class PermissionUtils {
  /**
   * 判断用户授权状态
   * @param permission
   * @returns
   */
  static checkPermissionGrant(permission: Permissions): boolean {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      const bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = atManager.checkAccessTokenSync(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 申请用户权限
   * @param context
   * @param permissions
   * @returns
   */
  static async requestPermissions(context: Context, permissions: Permissions[]): Promise<boolean> {
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(context, permissions)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          console.info(TAG, 'permissions granted: ' + JSON.stringify(permissions));
          return true;
        }
        // 二次向用户申请
        if ((result.dialogShownResults ?? []).some(v => !v)) {
          console.info(TAG, 'start reapply permissions: ' + JSON.stringify(permissions));
          try {
            const resp = await atManager.requestPermissionOnSetting(context, permissions);
            return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
          } catch (error) {
            console.error(TAG, 'requestPermissionOnSetting fail, error: ' + JSON.stringify(error));
            return false;
          }
        }
        return false;
      })
      .catch((error: BusinessError) => {
        console.error(TAG, 'requestPermissionsFromUser fail, error: ' + JSON.stringify(error));
        return false;
      });
  }
}