import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { CommonConstants, Logger, PopViewUtils } from 'utils';

export class Params {
  phones: string[] = [];

  constructor(phones: string[]) {
    this.phones = phones;
  }
}

function callPhone(value: string) {
  try {
    const canUse = canIUse('SystemCapability.Applications.Contacts');
    if (!canUse) {
      promptAction.showToast({ message: $r('app.string.call_phone_error') });
      return;
    }
    call.makeCall(value, (err: BusinessError) => {
      if (!err) {
        Logger.info('make call success.');
      } else {
        Logger.error('make call fail, err is:' + JSON.stringify(err));
      }
    });
  } catch (e) {
    promptAction.showToast({ message: $r('app.string.call_phone_error') });
  }
}

@Extend(Text)
function textStyle() {
  .fontSize(18)
  .fontColor('#007dff')
  .width(CommonConstants.FULL_PERCENT)
  .height(48)
  .textAlign(TextAlign.Center)
  .backgroundColor($r('app.color.common_card_bg'))
  .borderRadius(8)
}

@Builder
export function DialogCallBuilder(params: Params) {
  Column({ space: 10 }) {
    ForEach(params.phones, (phone: string) => {
      Text(phone).textStyle().onClick(() => {
        callPhone(phone);
      })
    }, (item: string) => item)
    Text($r('app.string.btn_common_cancel')).textStyle().onClick(() => {
      PopViewUtils.closePopView();
    })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10, bottom: 30 })

}