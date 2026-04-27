import {
  abilityAccessCtrl,
  bundleManager,
  Permissions,
  common,
  PermissionRequestResult
} from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '../basic/GlobalContext';

const TAG: string = 'PermissionUtil';

export class PermissionUtil {
  static checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    return new Promise(async (resolve, _) => {
      let atManager = abilityAccessCtrl.createAtManager();
      // 默认权限是失败
      let grantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

      // 获取应用程序的accessTokenID
      let tokenId: number = 0;
      try {
        let bundleInfo =
          await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
        tokenId = bundleInfo?.appInfo?.accessTokenId;
      } catch (error) {
      }

      // 校验应用是否被授予权限
      try {
        grantStatus = await atManager.checkAccessToken(tokenId, permission);
      } catch (error) {
      }
      resolve(grantStatus);
    });
  }

  static checkPermissions(permissions: Permissions): Promise<boolean> {
    return new Promise(async (resolve, reject) => {
      PermissionUtil.checkPermissionGrant(permissions)
        .then((grantStatus: abilityAccessCtrl.GrantStatus) => {
          if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            // 已经授权，可以继续访问目标操作
            resolve(true);
          } else {
            // 申请权限
            let permissionsList: Array<Permissions> = [permissions];
            // 精准定位，需要将模糊定位和精准定位一起请求
            if (permissions === 'ohos.permission.LOCATION') {
              permissionsList = ['ohos.permission.LOCATION',
                'ohos.permission.APPROXIMATELY_LOCATION'];
            }
            PermissionUtil.reqPermissionsFromUser(permissionsList)
              .then((_: number) => {
                resolve(true);
              })
              .catch((err: BusinessError) => {
                reject(err);
              });
          }
        })
        .catch((err: BusinessError) => {
          reject(err);
        })
    });
  }

  static reqPermissionsFromUser(permissions: Array<Permissions>, uiContext?: UIContext): Promise<number> {
    return new Promise(async (resolve, reject) => {
      let atManager = abilityAccessCtrl.createAtManager();
      let abilityContext: common.UIAbilityContext;
      if (uiContext) {
        abilityContext = uiContext.getHostContext() as common.UIAbilityContext;
      } else {
        abilityContext = GlobalContext.getUIAbilityContext() as common.UIAbilityContext;
      }

      atManager.requestPermissionsFromUser(abilityContext, permissions)
        .then((data: PermissionRequestResult) => {
          let logStatus = 'requestPermissionsFromUser ';
          let isAllow = true;
          for (let i = 0; i < data?.authResults?.length; i++) {
            let grantStatus = data?.authResults?.[i];
            let permissionStr = data?.permissions?.[i];
            logStatus = logStatus + permissionStr + ' req';
            if (grantStatus === -1) {
              logStatus = logStatus + ' false; ';
              isAllow = false;
            } else {
              logStatus = logStatus + ' true; ';
            }
          }

          if (isAllow) {
            // 用户授权，可以继续访问目标操作
            resolve(0);
          } else {
            // 请到系统应用“设置”中打开相应的权限。路径：设置 > 隐私 > 权限管理 > 应用 > 目标应用
            let err: BusinessError = {
              message: `用户拒绝授权`,
              code: 401,
              name: `用户拒绝授权`
            }
            reject(err);
          }
        })
        .catch((err: BusinessError) => {
          reject(err);
        })
    });
  }

  /**
   * 用于UIAbility/UIExtensionAbility二次拉起权限设置弹框
   *
   * @param permissions 权限名称
   * @param context UIAbility上下文
   */
  static requestPermissionOnSetting(permissions: Array<Permissions>, context: common.UIAbilityContext) {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(context, permissions)
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      })
      .catch((err: BusinessError) => {
      });
  }
}