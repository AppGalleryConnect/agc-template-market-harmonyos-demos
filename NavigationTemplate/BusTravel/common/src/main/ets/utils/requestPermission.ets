import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { bundleManager } from '@kit.AbilityKit';

// 检查是否授权
export function checkPermission(permissions: Array<Permissions>) {
  const atManager = abilityAccessCtrl.createAtManager();
  const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
  // 提取 tokenID 标识
  const tokenID = bundleInfo.appInfo.accessTokenId
  // 校验应用是否被授予权限
  const authResults = permissions.map((item) => atManager.checkAccessTokenSync(tokenID, item))
  // 返回是否已授权结果
  return authResults.some(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
}

// 动态获取权限
export function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext,
  callBack ?: () => void): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  atManager.requestPermissionsFromUser(context, permissions).then((data: PermissionRequestResult) => {
    let grantStatus: Array<number> = data.authResults;
    if (grantStatus[0] === 0) {
      console.log('授权成功')
      callBack
    } else {
      console.log('用户拒绝授权')
    }
  }).catch((err: BusinessError) => {
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}