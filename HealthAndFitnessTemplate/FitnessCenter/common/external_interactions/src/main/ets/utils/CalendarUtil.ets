import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = '[CalendarUtil]';

export function getCalendarPermission(context: common.UIAbilityContext): Promise<string> {
  const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
  let atManager = abilityAccessCtrl.createAtManager();
  return new Promise((resolve, reject) => {
    atManager.requestPermissionsFromUser(context, permissions).then((result: PermissionRequestResult) => {
      if (result.authResults[0] === -1 && result.authResults[1] === -1) {
      resolve('failed')
      } else {
        resolve('success')
      }
    }).catch((error: BusinessError) => {
      reject('failed')
      Logger.error(TAG, `get Permission error, error. Code: ${error.code}, message: ${error.message}`);
    })
  })
}
