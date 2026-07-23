import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

/**
 * 麦克风权限申请
 * @param permissions
 * @param context
 * @returns
 */
export async function requestPermission(permissions: Permissions[],
  context: common.UIAbilityContext): Promise<number> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  try {
    let data = await atManager.requestPermissionsFromUser(context, permissions);
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] !== 0) {
        return grantStatus[i];
      } else {
        return 0;
      }
    }
  } catch (error) {
    return -1;
  }
  return -1;
}
