import { Constants, startCallDialog } from 'common'

@Builder
export function TitleBuilder() {
  Text('联系客服')
    .fontSize($r('sys.float.Title_S'))
    .fontColor($r('sys.color.font_primary'))
    .fontSize(FontWeight.Medium)
}

@Builder
export function CallContentBuilder(callback: () => void = () => {
}) {
  Column() {
    Column() {
      Column({ space: Constants.CONTAINER_SPACE_TWENTY }) {
        Text('01234-567890')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize(FontWeight.Medium)
          .margin({ bottom: 24, top: 24 })
      }

      Row({ space: Constants.CONTAINER_SPACE_TEN }) {
        Image($r('app.media.highlight')).width($r('app.float.call_icon_size')).height($r('app.float.call_icon_size'))
        Text('一键拨号')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .borderRadius(Constants.RADIUS_EIGHTEEN)
      .width(Constants.FULL_PERCENT_WIDTH)
      .padding({ top: $r('app.float.common_margin_twelve'), bottom: $r('app.float.common_margin_twelve') })
      .backgroundColor($r('sys.color.background_emphasize'))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        /*
         * 拉起拨号界面并指定号码
         * */
        startCallDialog('01234-567890')
      })

      Row() {
        Text('取消')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
      }
      .borderRadius(Constants.RADIUS_EIGHTEEN)
      .width(Constants.FULL_PERCENT_WIDTH)
      .padding({ top: $r('app.float.common_margin_twelve'), bottom: $r('app.float.common_margin_twelve') })
      .margin({
        top: $r('app.float.common_margin_twelve'),
      })
      .onClick(() => {
        callback()
      })
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .padding({
      left: $r('app.float.common_padding_twenty_four'), right: $r('app.float.common_padding_twenty_four'),
    })
    .backgroundColor($r('sys.color.background_primary'))
    .width($r('app.float.mine_page_width'))
    .height($r('app.float.mine_page_height'))
    .borderRadius({ topLeft: Constants.RADIUS_TWELVE, topRight: Constants.RADIUS_TWELVE })
    .justifyContent(FlexAlign.Start)
  }
  .height('100%')
  .justifyContent(FlexAlign.End)
  .backgroundColor($r('sys.color.background_secondary'))
}