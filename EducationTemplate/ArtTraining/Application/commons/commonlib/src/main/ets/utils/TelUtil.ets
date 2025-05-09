import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[TelUtil]';

export class TelUtil {
  public static makeCall(phoneNum: string | undefined) {
    if (!phoneNum) {
      Logger.error(TAG, 'there is no phone number to call');
    }
    if (canIUse('SystemCapability.Applications.Contacts') && phoneNum) {
      call.makeCall(phoneNum, (error: BusinessError) => {
        if (error) {
          Logger.error(TAG, 'make call fail, error is: ' + JSON.stringify(error));
        } else {
          Logger.info(TAG, 'make call success.');
        }
      });
    } else {
      promptAction.showToast({ message: '当前设备暂不支持拉起拨号界面' });
    }
  }
}