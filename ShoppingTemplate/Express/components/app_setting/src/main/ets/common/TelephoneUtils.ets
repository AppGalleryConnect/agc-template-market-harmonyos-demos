import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

const TAG = '[TelephoneUtils]';

export class TelephoneUtils {
  /**
   * 拨打电话
   * @param tel
   */
  public static callPhone(tel: string) {
    if (canIUse('SystemCapability.Applications.Contacts')) {
      call.makeCall(tel).catch((err: BusinessError) => {
        Logger.error(TAG, 'make call fail, err is:' + JSON.stringify(err));
      })
    } else {
      Logger.error(TAG, 'Contacts not available by this device.');
    }
  }
}