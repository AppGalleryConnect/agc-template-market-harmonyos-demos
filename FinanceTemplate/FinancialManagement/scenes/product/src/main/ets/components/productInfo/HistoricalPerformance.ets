import { FormatUtil, RouterMap } from 'commonlib'
import { IHistoricalPerformance } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { ProductInfoVM } from '../../viewModels/ProductInfoVM'
import { CommonHeaderRule } from './CommonHeaderRule'
import { HistoricalPerformanceList } from './HistoricalPerformanceList'

@ComponentV2
export struct HistoricalPerformance {
  vm: ProductInfoVM = ProductInfoVM.instance

  build() {
    Column() {
      CommonHeaderRule({
        text: '历史业绩', changeValue: () => {
          FormatUtil.jumpToNext(RouterMap.HISTORICAL_PERFORMANCE, this.vm.productInfo)
        }
      })

      HistoricalPerformanceList({ productHistoricalPerformance: this.vm.productHistoricalPerformance })

      Row() {
        Text('温馨提示：理财产品过往业绩不代表其未来表现，不等于理财产品实际收益，投资须谨慎。')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .padding({
        top: 9,
        bottom: 12,
        left: 8,
        right: 8
      })
      .borderRadius(8)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
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