import { phoneRouterControl } from 'oh_router';

@ComponentV2
export struct MyOrderTitleView {
  // 是否需要打开热线上拉框
  @Param @Require changeIsHotline: (isHotline: boolean) => void

  build() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          phoneRouterControl.popPage()
        })

      Text('订单详情')
        .font({ size: 20 })
        .layoutWeight(1)
        .margin({ left: 5 })
        .fontColor('rgba(0, 0, 0, 1)')
        .textAlign(TextAlign.Start)

      Image($r('app.media.ic_listen_help'))
        .width(24)
        .onClick(() => {
          this.changeIsHotline(true)
        })
        .height(24)
    }
    .width('100%')
    .height(56)
    .backgroundColor('rgba(255, 255, 255, 1)')
    .padding({
      left: 16,
      right: 16,
    })
    .alignItems(VerticalAlign.Center)
  }
}