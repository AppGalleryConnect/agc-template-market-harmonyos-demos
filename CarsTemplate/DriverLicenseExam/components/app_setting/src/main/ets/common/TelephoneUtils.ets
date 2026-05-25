import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = '[TelephoneUtils]';

export class TelephoneUtils {
  /**
   * 拨打电话
   * @param tel
   */
  public static callPhone(tel: string) {
    if (canIUse('SystemCapability.Applications.Contacts')) {
      try {
        call.makeCall(tel, (err: BusinessError) => {
          if (!err) {
            Logger.info(TAG, 'make call success.');
          } else {
            Logger.error(TAG, 'make call fail, err is:' + JSON.stringify(err));
          }
        });
      } catch (error) {
        Logger.error(TAG, JSON.stringify(error))
      }

    } else {
      Logger.error(TAG, 'Contacts not available by this device.');
    }
  }
}