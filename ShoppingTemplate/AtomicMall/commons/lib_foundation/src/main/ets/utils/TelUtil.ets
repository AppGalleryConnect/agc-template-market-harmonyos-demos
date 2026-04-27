import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[TelUtil]';

export class TelUtil {
  /**
   * 拨打电话
   * @param tel
   */
  public static callPhone(tel: string) {
    if (canIUse('SystemCapability.Applications.Contacts')) {
      call.makeCall(tel)
        .then(() => {
          UtilLog.info(TAG, 'make call success.');
        })
        .catch((err: BusinessError) => {
          UtilLog.error(TAG, 'make call fail, err is:' + err.code);
        });
    } else {
      UtilLog.error(TAG, 'Contacts not available by this device.');
    }
  }
}