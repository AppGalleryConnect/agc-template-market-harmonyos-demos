import { Constants } from '../constants/Common'
import { SheetHeaderComp } from './SheetHeaderComp'

@Builder
export function paySheetBuilder(totalMoney: number, close: (flag: boolean) => void) {
  Column() {
    SheetHeaderComp({
      title: $r('app.string.select_pay_type'), close: () => {
        close(false)
      },
    })

    Column() {
      Row() {
        Text($r('app.string.yuan_params', `${totalMoney}`))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).margin({ top: 12 })

      Divider().margin({ top: 12, bottom: 12 })
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_huawei_pay')).width(24)
            Text($r('app.string.huawei_pay'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
              .margin({ left: 8 })
          }

          Radio({ value: '', group: 'radioGroup' })
            .checked(true)
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.multi_color_09'),
            })
            .height(20)
            .width(20)
        }
        .width(Constants.FULL_SIZE)
        .height(48)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 16,
          right: 16,
          top: 14,
          bottom: 14,
        })

        Row() {
          Button($r('app.string.pay_now'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .width(Constants.FULL_SIZE)
            .constraintSize({ maxWidth: Constants.FULL_SIZE })
            .padding({
              top: 6,
              bottom: 6,
            })
            .margin(2)
            .backgroundColor($r('sys.color.multi_color_09'))
            .onClick(() => {
              close(true)
            })
        }.margin({ bottom: 32 })
      }.layoutWeight(1).justifyContent(FlexAlign.SpaceBetween)
    }
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius({ topLeft: 12, topRight: 12 })
    .margin({ top: 8 })
  }
  .width(Constants.FULL_SIZE)
  .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
  .backgroundColor($r('sys.color.background_secondary'))
  .borderRadius({ topLeft: 32, topRight: 32 })
  .constraintSize({ maxWidth: Constants.FULL_SIZE })
}