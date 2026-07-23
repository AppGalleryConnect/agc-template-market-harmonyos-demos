import { abilityAccessCtrl, bundleManager, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Logger } from './Logger';

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

  /**
   * 获取当前所在位置
   * @returns
   */
  static async getLocation(uiContext: UIContext): Promise<geoLocationManager.Location> {
    return new Promise(async (resolve, reject) => {
      const locationPermission: Permissions = 'ohos.permission.APPROXIMATELY_LOCATION';
      // 检查权限
      if (!PermissionUtils.checkPermissionGrant(locationPermission)) {
        const granted =
          await PermissionUtils.requestPermissions(uiContext.getHostContext() as Context, [locationPermission]);
        if (!granted) {
          ToastDialog.showToast({ message: '权限获取失败' })
          reject()
          return;
        }
      }
      try {
        let requestInfo: geoLocationManager.CurrentLocationRequest = {
          'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
          'maxAccuracy': 0,
        };
        geoLocationManager.getCurrentLocation(requestInfo).then((result) => {
          resolve(result);
        }).catch((error: BusinessError) => {
          Logger.error(TAG, 'getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(error));
          reject(error)
        });
      } catch (err) {
        if (err.code === '3301100') {
          ToastDialog.showToast({ message: '检测到您尚未打开位置开关，请到设置里打开“访问我的位置”。', duration: 3000 })
        }
        Logger.error(TAG, 'errCode:' + err.code + ', message:' + err.message);
      }
    })
  }
}