import { FormatUtil, RouterMap } from 'commonlib'
import { ProductInfoVM } from '../../viewModels/ProductInfoVM'
import { CommonHeaderRule } from './CommonHeaderRule'
import { CommonRowRule } from './CommonRowRule'

@ComponentV2
export struct BuyRule {
  vm: ProductInfoVM = ProductInfoVM.instance

  build() {
    Column() {
      CommonHeaderRule({
        text: '购买规则', changeValue: () => {
          FormatUtil.jumpToNext(RouterMap.RULE, { id: this.vm.productInfo?.id, index: 0 })
        }
      })

      CommonRowRule({
        text: '购买金额', value: this.vm.productBuyRule?.minimumPurchaseAmount + '元起购，' +
          this.vm.productBuyRule?.minimumPurchaseAmount + '元递增'
      })

      CommonRowRule({ text: '认购费率', value: this.vm.productBuyRule?.purchaseRate + '%' })

      CommonRowRule({ text: '申购费率', value: this.vm.productBuyRule?.subscriptionRate + '%' })

      Row() {
        Row() {
          Text('购买时间')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('25%')

        Row() {
          Text(this.vm.productBuyRule?.date)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .justifyContent(FlexAlign.End)
        .width('75%')
      }
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })
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