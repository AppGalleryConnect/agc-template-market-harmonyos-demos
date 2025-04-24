import { promptAction } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import Logger from './Logger';

export function triggerForCall(phoneNo: string) {
  call.makeCall(phoneNo, (err) => {
    if (err) {
      Logger.error('make call success');
      promptAction.showToast({ message: '拨打号码失败' });
    } else {
      Logger.info('make call success');
    }
  });
}