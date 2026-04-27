import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { Logger } from 'module_ui_base';

const TAG = '[TelephoneUtils]';

export class TelephoneUtils {
  /**
   * 拨打电话
   * @param tel
   */
  public static callPhone(tel: string) {
    if (canIUse('SystemCapability.Applications.Contacts')) {
      call.makeCall(tel)
        .then(() => {
          Logger.info(TAG, 'make call success.');
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, 'make call fail, err is:' + err.code);
        });
    } else {
      Logger.error(TAG, 'Contacts not available by this device.');
    }
  }
}
