import { Constants } from '../constants/Common'
import { StoreInfo } from '../models/ResponseModel'

@CustomDialog
export struct BusinessTimeDialog {
  @Consume('storeInfo') storeInfo?: StoreInfo
  controller?: CustomDialogController

  build() {
    Stack() {
      Row()
        .width(Constants.FULL_SIZE)
        .height(135)
        .backgroundImage($r('app.media.bg_business'))
        .backgroundImageSize({ width: Constants.FULL_SIZE, height: 135 })
      Column(){
        Row() {
          Text($r('app.string.store_rest')).fontSize($r('sys.float.Subtitle_L')).fontColor($r('sys.color.font_primary'))
        }

        Image($r('app.media.business_time')).width(126).height(168).margin({ top: 24 })

        Row({space:12}) {
          Row() {
            Image($r('app.media.icon_clock')).width(24).margin(3)
            Column() {
              Text($r('app.string.business_time')).fontSize($r('sys.float.Subtitle_L')).fontColor($r('sys.color.font_primary'))
              Text('Business Hours')
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
            }.margin({ left: 8 })
          }.alignItems(VerticalAlign.Top)

          Column() {
            Row() {
              Text(`AM ${this.storeInfo?.time}-${this.storeInfo?.time2}`)
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .padding({ left: 12, right: 12,top:8,bottom:8 })
            .borderRadius(4)

            Row() {
              Text(`PM ${this.storeInfo?.time3}-${this.storeInfo?.time4}`)
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .padding({ left: 12, right: 12,top:8,bottom:8 })
            .borderRadius(4)
            .margin({ top: 4 })
          }
        }
        .width(Constants.FULL_SIZE)
        .alignItems(VerticalAlign.Top)
        .margin({ top: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
      } .padding({
        top: 24,
        bottom: 22,
        left: 32,
        right: 32
      })
    }.alignContent(Alignment.Top)
  }
}