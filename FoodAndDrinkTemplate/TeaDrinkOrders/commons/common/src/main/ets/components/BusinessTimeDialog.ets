import { Constants } from '../constants/Common';

@CustomDialog
export struct BusinessTimeDialog {
  @Prop businessHoursAM: string
  @Prop businessHoursPM: string
  controller?: CustomDialogController

  build() {
    Stack() {
      Row()
        .height(135)
        .backgroundImage($r('app.media.business_bg'))
        .backgroundImageSize({ width: Constants.FULL_SIZE, height: 135 })

      Column() {
        Text($r('app.string.store_rest')).fontSize(18).fontColor($r('sys.color.font_primary')).margin({ top: 24 })
        Image($r('app.media.business_time')).width(126).height(168).margin({ top: 24 })

        Row() {
          Row() {
            Image($r('app.media.ic_clock')).width(16).margin({ top: 2 })
            Column() {
              Text($r('app.string.business_time')).fontSize(16).fontColor($r('sys.color.font_primary')).lineHeight(20)
              Text('Business Hours')
                .fontSize(8)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 2 })
            }.margin({ left: 12 })
          }.alignItems(VerticalAlign.Top)

          Column() {
            Row() {
              Text(this.businessHoursAM)
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .lineHeight(20)
            }
            .width(116)
            .height(28)
            .backgroundColor('rgba(212,246,107,0.2)')
            .padding({ left: 12, right: 12 })
            .borderRadius(2)

            Row() {
              Text(this.businessHoursPM)
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .lineHeight(20)
            }
            .width(116)
            .height(28)
            .backgroundColor('rgba(212,246,107,0.2)')
            .margin({ top: 6 })
            .padding({ left: 12, right: 12 })
            .borderRadius(2)
          }
        }
        .width(Constants.FULL_SIZE)
        .alignItems(VerticalAlign.Top)
        .margin({ top: 24 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }.alignContent(Alignment.Top)
    .padding({
      left: 33,
      right: 32,
    })
  }
}