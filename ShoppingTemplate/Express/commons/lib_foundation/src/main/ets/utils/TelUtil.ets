import { BusinessError } from '@kit.BasicServicesKit'
import { call } from '@kit.TelephonyKit'
import { Logger } from '../utils/Logger'
import { PopViewUtils } from './PopViewUtil'

const TAG = '[CallTelSheet]'

export interface CallTelBuilderParam {
  tel: string
  close: () => void
}

@Builder
function callTelSheetBuilder(param: CallTelBuilderParam) {
  CallTelSheetView({
    tel: param.tel,
    close: param.close
  })
}

@ComponentV2
struct CallTelSheetView {
  @Param tel: string = '';
  @Event close: () => void;

  build() {
    Column() {
      Column({ space: 12 }) {
        Text(this.tel)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))

        Blank()

        Row() {
          Image($r('app.media.ic_tel_white')).width(24)
          Text('一键拨号')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .borderRadius(18)
        .constraintSize({ maxWidth: '100%' })
        .padding({ top: 8, bottom: 8 })
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            try {
              call.makeCall(this.tel, (err: BusinessError) => {
                if (!err) {
                  Logger.info(TAG, 'make call success.');
                } else {
                  Logger.info(TAG, 'make call fail, err is:' + JSON.stringify(err));
                }
              });
            } catch (e) {
              Logger.error(TAG, 'make call fail, e is:' + JSON.stringify(e));
            }
          } else {
            Logger.error(TAG, 'Contacts not available by this device.');
          }
          this.close?.()
        })

        Row() {
          Text('取消')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: '100%' })
            .padding({ top: 8, bottom: 8 })
            .margin(2)
            .borderRadius(18)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
        }
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.close?.()
        })
      }
      .width('100%')
      .height('100%')
      .constraintSize({ maxWidth: '100%' })
      .padding({ top: 20, bottom: 16, left: 12, right: 12 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.background_primary'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
  }
}

export class TelUtil {
  public static makeCall(title: string = '联系客服', phoneNum: string) {
    const param: CallTelBuilderParam = {
      tel: phoneNum,
      close: () => {
        PopViewUtils.closeSheet();
      }
    }
    PopViewUtils.showSheet(wrapBuilder(callTelSheetBuilder), {
      height: 280,
      blurStyle: BlurStyle.Thick,
      preferType: SheetType.CENTER,
      showClose: true,
      backgroundColor: $r('sys.color.background_fourth'),
      title: { title },
    }, param)
  }
}