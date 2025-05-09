import { FormatUtil, RouterMap } from 'commonlib'
import { PositionInfoVM } from '../viewModels/PositionInfoVM'

@ComponentV2
export struct PurchaseBar {
  vm: PositionInfoVM = PositionInfoVM.instance

  build() {
    Column() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Button('赎回')
            .width(155)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor('#E4480C')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (this.vm.isLogin) {
                FormatUtil.jumpToNext(RouterMap.REDEMPTION, this.vm.positionInfo)
              } else {
                FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
              }
            })

          Button('追加购买')
            .width(156)
            .backgroundColor('#E4480C')
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (this.vm.isLogin) {
                FormatUtil.jumpToNext(RouterMap.PURCHASE, { id: this.vm.positionInfo?.productId, isPurchase: true })
              } else {
                FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
              }
            })
        }
      }
      .height(58)
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 28 })
    }
    .width('100%')
    .height(86)
    .translate({ x: 0, y: 28 })
    .backgroundColor(Color.White)
    .position({ bottom: 0 })
  }
}