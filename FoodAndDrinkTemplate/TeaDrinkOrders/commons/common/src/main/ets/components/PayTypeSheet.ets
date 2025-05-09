import { Constants } from '../constants/Common'
import { SheetHeaderComp } from './SheetHeaderComp'

@Builder
export function PayTypeSheetBuilder(totalMoney: number, close: (flag: boolean) => void) {
  Column() {
    SheetHeaderComp({
      title: $r('app.string.select_pay_type'), close: () => {
        close(false)
      },
    })

    Column() {
      Row() {
        Text($r('app.string.wait_pay'))
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
        Text($r('app.string.yuan_params', `${totalMoney}`))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).margin({ top: 12 })

      Divider().margin({ top: 12, bottom: 12 })
      Column({ space: 24 }) {
        Row() {
          Row() {
            Image($r('app.media.ic_huawei_pay')).width(24)
            Text($r('app.string.huawei_pay'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 8 })
            Text($r('app.string.huawei_pay'))
              .fontSize(8)
              .fontColor($r('sys.color.multi_color_08'))
              .padding({left:8,right:8,top:3,bottom:3})
              .margin({ left: 4 })
              .backgroundColor('#1AED6F21')
              .borderRadius(14)
          }

          Radio({ value: '', group: 'radioGroup' })
            .checked(true)
            .radioStyle({
              checkedBackgroundColor: '#486602',
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
            .backgroundColor('#486602')
            .onClick(() => {
              close(true)
            })
        }.margin({ bottom: 32, left: 24, right: 24 })
      }.layoutWeight(1).justifyContent(FlexAlign.SpaceBetween).margin({ top: 12 })
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