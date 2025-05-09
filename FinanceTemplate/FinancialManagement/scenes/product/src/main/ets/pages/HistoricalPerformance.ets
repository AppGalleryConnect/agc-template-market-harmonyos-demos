import { IHistoricalPerformance } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { HistoricalPerformanceList } from '../components/productInfo/HistoricalPerformanceList';
import { HistoricalPerformanceVM } from '../viewModels/HistoricalPerformanceVM';

@Builder
export function HistoricalPerformanceBuilder() {
  HistoricalPerformance()
}

@ComponentV2
struct HistoricalPerformance {
  vm: HistoricalPerformanceVM = HistoricalPerformanceVM.instance

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Column() {
              Text(this.vm.productInfo?.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Text(this.vm.productInfo?.number)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .margin({ bottom: 8 })
                .fontColor($r('sys.color.font_secondary'))
              Divider().color($r('sys.color.comp_divider'))
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 15 })

            HistoricalPerformanceList({ productHistoricalPerformance: this.vm.historicalPerformanceList })
          }
          .backgroundColor(Color.White)
          .padding({
            top: 16,
            bottom: 8,
            left: 12,
            right: 12
          })
          .margin({ bottom: 16 })
          .borderRadius(16)

          Column() {
            Text('温馨提示： ')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
            Text('1.理财产品过往业绩不代表其未来表现，不等于理财产品实际收益，投资需谨慎。 ')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
            Text('2.本产品成立于2024年2月28日，数据截止至2025年03月06日，过往业绩相关历史数据已经托管人核对。')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
          }
          .padding({
            top: 9,
            bottom: 12,
            left: 8,
            right: 8
          })
          .alignItems(HorizontalAlign.Start)
        }
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
      .scrollBar(BarState.Off)
    }
    .title('历史业绩')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}