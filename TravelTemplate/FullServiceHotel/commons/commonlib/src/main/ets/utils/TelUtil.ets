import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PopViewUtils } from './PopViewUtils';

const TAG = '[TelUtil]';

class PhoneParam {
  phoneNum: string;

  constructor(phoneNum: string) {
    this.phoneNum = phoneNum;
  }
}

@Builder
function phoneNumDialog(param: PhoneParam) {
  Column({ space: 8 }) {
    Row() {
      Text('联系电话：' + param.phoneNum)
        .fontColor($r('app.color.font_color_link'));
    }
    .onClick(() => {
      call.makeCall(param.phoneNum, (error: BusinessError) => {
        if (error) {
          Logger.error(TAG, 'make call fail, error is: ' + JSON.stringify(error));
        } else {
          Logger.info(TAG, 'make call success.');
        }
      });
    })
    .optionContainerStyle();

    Row() {
      Text('取消')
        .fontColor($r('app.color.font_color_link'));
    }
    .optionContainerStyle()
    .onClick(() => {
      PopViewUtils.closeDialog();
    });
  }
  .width($r('app.string.width_percent_full'))
  .margin({ bottom: $r('app.string.margin_l') });
}

@Extend(Row)
function optionContainerStyle() {
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('app.color.system_color_background_white'))
  .borderRadius(99)
  .padding($r('app.string.padding_m'))
  .width('90%');
}

export class TelUtil {
  public static makeCall(phoneNum: string | undefined) {
    if (!phoneNum) {
      Logger.error(TAG, 'there is no phone number to call');
    }
    const builder = wrapBuilder(phoneNumDialog);
    if (canIUse('SystemCapability.Applications.Contacts') && phoneNum) {
      PopViewUtils.openDialog<PhoneParam>(
        builder,
        { alignment: DialogAlignment.Bottom },
        new PhoneParam(phoneNum),
      );
    } else {
      promptAction.showToast({ message: '当前设备暂不支持拉起拨号界面' });
    }
  }
}