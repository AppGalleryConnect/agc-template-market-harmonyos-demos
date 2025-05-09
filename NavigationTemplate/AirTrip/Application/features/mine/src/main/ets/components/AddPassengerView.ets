import { AppRouter } from 'common'

@ComponentV2
export struct AddPassengerView {

  build() {
    Row({space: 8}) {
      Image($r('app.media.ic_add_passenger')).width(24).height(24)
      Text('添加乘机人').fontSize(16).fontColor($r('app.color.color_btn_emphasize_bg')).fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.white'))
    .padding(16)
    .borderRadius(16)
    .onClick(() => {
      AppRouter.push({
        url: 'AddPassengerPage',
      })
    })
  }
}