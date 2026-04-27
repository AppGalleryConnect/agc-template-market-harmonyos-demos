import { abilityAccessCtrl, common } from '@kit.AbilityKit';

// 麦克风权限申请
export async function requestPermission(context: common.UIAbilityContext): Promise<boolean> {
  let tmpManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let data = await tmpManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE']);
  let results: Array<number> = data.authResults;
  let length: number = results.length;
  for (let i = 0; i < length; i++) {
    if (results[i] !== 0) {
      return false;
    }

    return true;
  }
  return false;
}