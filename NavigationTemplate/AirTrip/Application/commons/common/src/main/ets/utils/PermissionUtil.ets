import { abilityAccessCtrl, common, Permissions, bundleManager } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';

export class PermissionUtil {
  static async checkPermissions(context: common.UIAbilityContext, permissions: Array<Permissions>): Promise<boolean> {
    let applyResult: boolean = false;
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil.checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        applyResult = true;
      } else {
        applyResult = false
      }
    }
    return new Promise(async (resolve, reject) => {
      if (applyResult) {
        resolve(true)
      } else {
        let result: boolean  = await PermissionUtil.requestPermissions(context, permissions)
        resolve(result)
      }
    })
  }

  static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    //获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`Failed to get bundle info for self. Code is ${err.code},message is ${err.message}`)
    }
    //校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`)
    }
    return grantStatus;
  }

  static async requestPermissions(context: common.UIAbilityContext, permissions: Array<Permissions>): Promise<boolean> {

    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus = await atManager.requestPermissionsFromUser(context, permissions);

    return new Promise((resolve, reject) => {
      let userGrant: boolean = grantStatus?.authResults.every((item: number) => item === 0)
      resolve(userGrant)
    })
  }
}
