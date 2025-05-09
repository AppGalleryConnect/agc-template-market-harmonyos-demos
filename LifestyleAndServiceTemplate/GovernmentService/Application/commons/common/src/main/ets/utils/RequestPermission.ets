import { abilityAccessCtrl, Permissions, bundleManager, PermissionRequestResult, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class RequestPermission {
  private permissions: Array<Permissions> =
    ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

  public async checkLocationPermission(): Promise<string> {
    let applyResult: boolean = false;
    for (let permission of this.permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        applyResult = true;
      } else {
        applyResult = false
      }
    }
    if (!applyResult) {
      return this.requestPermissions();
    }
    return Promise.resolve('pass')
  }

  public async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    console.info('Succeeded in getting Bundle.');
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;

    // 校验应用是否被授予权限
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
    console.info('Succeeded in checking access token.');
    return grantStatus;
  }

  // 如果没有被授予定位权限，动态向用户申请授权
  public async requestPermissions(): Promise<string> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      let data: PermissionRequestResult =
        await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext,
          this.permissions)
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      let status: string = 'failed'
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          status = 'pass'
        } else {
          status = 'failed'
        }
      }
      return Promise.resolve(status)
    } catch (err) {
      console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      return Promise.reject('failed')
    }
  }
}