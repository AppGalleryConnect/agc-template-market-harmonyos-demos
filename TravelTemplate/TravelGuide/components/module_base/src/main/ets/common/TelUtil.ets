import { Logger } from './Logger';
import { PopViewUtils } from './PopViewUtil';
import { promptAction } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonUtil } from './CommonUtil';

const TAG = '[TelUtil]';

class PhoneParam {
  label: string;
  phoneNum: string;

  constructor(label: string, phoneNum: string) {
    this.label = label
    this.phoneNum = phoneNum;
  }
}

@Builder
function phoneNumDialog(param: PhoneParam) {
  Column({ space: 8 }) {
    Row() {
      Text(param.label)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Image($r('app.media.ic_close'))
        .width(40)
        .height(40)
        .onClick(() => {
          PopViewUtils.closeDialog();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 30, bottom: 16 })

    Column() {
      Row() {
        Text(CommonUtil.encryptPhoneNo(param.phoneNum))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Row() {
        Image($r('app.media.ic_tel'))
          .width(24)
          .height(24)
        Text('一键拨号')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(40)
      .backgroundColor('#0A59F7')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })
      .borderRadius(20)
      .onClick(() => {
        try {
          call.makeCall(param.phoneNum, (error: BusinessError) => {
            if (error) {
              Logger.error(TAG, 'make call fail, error is: ' + JSON.stringify(error));
            } else {
              Logger.info(TAG, 'make call success.');
            }
          });
        } catch (err) {
        }
      })

      Row() {
        Text('取消')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(40)
      .backgroundColor('rgba(0,0,0,0.05)')
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .onClick(() => {
        PopViewUtils.closeDialog();
      })
    }
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .borderRadius(16)
  }
  .padding({ left: 16, right: 16 })
  .width('100%')
  .height(280)
  .backgroundColor('#F1F3F5')
  .borderRadius({ topLeft: 16, topRight: 16 })
}

@Extend(Row)
function optionContainerStyle() {
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius(99)
  .padding(16)
  .width('90%');
}

export class TelUtil {
  public static makeCall(label: string, phoneNum: string | undefined) {
    if (!phoneNum) {
      Logger.error(TAG, 'there is no phone number to call');
    }
    const builder = wrapBuilder(phoneNumDialog);
    if (canIUse('SystemCapability.Applications.Contacts') && phoneNum) {
      PopViewUtils.openDialog<PhoneParam>(
        builder,
        { alignment: DialogAlignment.Bottom },
        new PhoneParam(label, phoneNum),
      );
    } else {
      promptAction.showToast({ message: '当前设备暂不支持拉起拨号界面' });
    }
  }
}