import { CommonRuleLine } from 'componentlib'
import { ProductInfoVM } from '../../viewModels/ProductInfoVM'

@ComponentV2
export struct PurchaseProcess {
  vm: ProductInfoVM = ProductInfoVM.instance

  build() {
    Column() {
      CommonRuleLine({
        isPurchase: true,
        confirmationDate: this.vm.purchaseProcess?.redemptionDate,
        redemptionDate: this.vm.purchaseProcess?.redemptionDate
      })
      Row() {
        Row()
          .width(4)
          .height(4)
          .backgroundColor($r('sys.color.icon_tertiary'))
          .borderRadius('50%')
          .margin({ left: 8, right: 4 })
        Text(`17:00点前购买，${this.vm.purchaseProcess?.confirmationDate}可查看持仓并开始计算收益`)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(32)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(8)
    }
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 12
    })
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
    .borderRadius(16)
  }
}