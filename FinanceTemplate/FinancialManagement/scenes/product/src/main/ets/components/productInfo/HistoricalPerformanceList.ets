import { IHistoricalPerformance } from 'network/src/main/ets/types/responseTypes/GetProductResp'

@ComponentV2
export struct HistoricalPerformanceList {
  @Param productHistoricalPerformance: IHistoricalPerformance[] = []

  build() {
    List() {
      ListItem() {
        Row() {
          Row() {
            Text('周期')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('50%')

          Row() {
            Text('涨跌幅')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('25%')

          Row() {
            Text('折合年化')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('25%')
          .justifyContent(FlexAlign.End)
        }
      }
      .margin({ bottom: 14 })

      ForEach(this.productHistoricalPerformance, (performance: IHistoricalPerformance, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Column() {
                Text(performance.cycle)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Text(performance.date)
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .width('50%')
              .alignItems(HorizontalAlign.Start)

              Row() {
                if (performance.risePrice !== 0) {
                  Text(performance.risePrice + '%')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#C15F2F')
                } else {
                  Text(performance.fallingPrice + '%')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.multi_color_04'))
                }

              }
              .width('25%')

              Row() {
                Text(performance.annualized + '%')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#C15F2F')
              }
              .width('25%')
              .justifyContent(FlexAlign.End)
            }
            .margin({ bottom: 9 })

            if (index !== this.productHistoricalPerformance.length - 1) {
              Divider().color($r('sys.color.comp_divider'))
            }
          }
        }
        .padding({ top: 6 })
      }, (item: IHistoricalPerformance[]) => JSON.stringify(item))
    }
    .margin({ bottom: 8 })
  }
}