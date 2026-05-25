import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { identifier } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'OaidUtils';

export async function requestOAID(context: Context): Promise<string | undefined> {
  // 向用户请求授权广告跨应用关联访问权限
  let isPermissionGranted: boolean = false;
  try {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const result: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
    isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  } catch (err) {
    const e = err as BusinessError;
    hilog.info(0x0000, TAG, `Failed to request permission. Code is ${e.code}, message is ${e.message}`);
  }
  if (isPermissionGranted) {
    hilog.info(0x0000, TAG, 'Succeeded in requesting permission');
    try {
      const oaid = await identifier.getOAID();
      hilog.info(0x0000, TAG, 'Succeeded in getting OAID');
      return oaid;
    } catch (err) {
      const e = err as BusinessError;
      hilog.info(0x0000, TAG, `Failed to get OAID. Code is ${e.code}, message is ${e.message}`);
    }
  } else {
    hilog.info(0x0000, TAG, 'Failed to request permission. User rejected');
  }
  return undefined;
}
