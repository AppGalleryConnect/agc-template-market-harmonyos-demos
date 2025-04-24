import { call } from '@kit.TelephonyKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { Constants } from '../constants/Common'
import { SheetHeaderComp } from './SheetHeaderComp'

@Builder
export function CallTelDialogBuilder(tel: string, close: () => void) {
  Column() {
    SheetHeaderComp({
      title: $r('app.string.contact_us'),
      close: () => {
        close()
      },
    })
    Column() {
      Text(`${tel.substring(0, tel.length - 8)}****${tel.substring(tel.length - 4)}`)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 20 })

      Row() {
        Image($r('app.media.ic_tel_btn')).width(14).margin(5)
        Text($r('app.string.call'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 4 })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(Constants.FULL_SIZE)
      .borderRadius(18)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .padding({
        top: 8,
        bottom: 8,
      })
      .margin({
        left: 2,
        right: 2,
        top: 32,
        bottom: 2,
      })
      .backgroundColor($r('sys.color.multi_color_09'))
      .onClick(() => {
        if (canIUse('SystemCapability.Applications.Contacts')) {
          call.makeCall(tel, (err: BusinessError) => {
            if (!err) {
              console.log('make call success.');
            } else {
              console.log('make call fail, err is:' + JSON.stringify(err));
            }
          });
        } else {
          console.error('Contacts not available by this device.');
        }
        close()
      })

      Row() {
        Text($r('app.string.cancel'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width(Constants.FULL_SIZE)
          .textAlign(TextAlign.Center)
          .constraintSize({ maxWidth: Constants.FULL_SIZE })
          .padding({
            top: 8,
            bottom: 8,
          })
          .margin(2)
          .borderRadius(18)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }.justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
      .onClick(() => {
        close()
      })
    }
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 8 })
    .padding({ top: 39, left: 12, right: 12 })
    .borderRadius({ topLeft: 12, topRight: 12 })

  }
  .width(Constants.FULL_SIZE)
  .height(309)
  .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
  .backgroundColor($r('sys.color.background_secondary'))
  .borderRadius({ topLeft: 32, topRight: 32 })
  .constraintSize({ maxWidth: Constants.FULL_SIZE })
}