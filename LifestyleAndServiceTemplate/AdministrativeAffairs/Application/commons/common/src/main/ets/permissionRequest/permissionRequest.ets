import { abilityAccessCtrl, common } from '@kit.AbilityKit';

export class PermissionRequestUtils {
  static context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    PermissionRequestUtils.context = context
  }

  public async locationPermissionRequest(): Promise<string> {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let result = await atManager.requestPermissionsFromUser(PermissionRequestUtils.context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'])
      if (result.authResults[0] !== 0 || result.authResults[1] !== 0) {
        return Promise.resolve('failed');
      } else {
        return Promise.resolve('success');
      }
    } catch (err) {
      return Promise.reject('failed');
    }
  }
}