import { IRevenueItem } from 'network/src/main/ets/types/responseTypes/GetRevenueInfoResp'
import { RevenueInfoVM } from '../viewModels/RevenueInfoVM'

@Builder
export function RevenueInfoBuilder() {
  RevenueInfo()
}

@ComponentV2
struct RevenueInfo {
  vm: RevenueInfoVM = RevenueInfoVM.instance

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.vm.revenueInfo) {
            Column() {
              Text('近1周收益(元)')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ bottom: 8 })
              Text() {
                if (this.vm.revenueInfo.totalRevenue > 0) {
                  Span(`+${this.vm.revenueInfo.totalRevenue}`)
                    .fontColor('#E4480C')
                } else if (this.vm.revenueInfo.totalRevenue === 0) {
                  Span('0.00')
                    .fontColor('#D1D1D6')
                } else {
                  Span(`${this.vm.revenueInfo.totalRevenue}`)
                    .fontColor('#64BB5C')
                }
              }
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(96)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Color.White)
            .margin({ bottom: 8 })

            List() {
              ForEach(this.vm.revenueInfo.revenueList, (revenueItem: IRevenueItem) => {
                ListItem() {
                  Stack({ alignContent: Alignment.Start }) {
                    if (revenueItem.revenue > 0) {
                      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                        Text(revenueItem.date)
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                        Text(revenueItem.revenue + '')
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                      }
                      .backgroundColor('#E4480C')
                      .width(this.vm.getWidth(revenueItem.revenue))
                      .height('100%')
                      .padding({ left: 8, right: 8 })
                    } else if (revenueItem.revenue === 0) {
                      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                        Text(revenueItem.date)
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                        Text('0.00')
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                      }
                      .width(this.vm.getWidth(revenueItem.revenue))
                      .backgroundColor('#D1D1D6')
                      .height('100%')
                      .padding({ left: 8, right: 8 })
                    } else {
                      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                        Text(revenueItem.date)
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                        Text(revenueItem.revenue + '')
                          .fontSize(12)
                          .fontWeight(FontWeight.Regular)
                          .fontColor($r('sys.color.font_on_primary'))
                      }
                      .width(this.vm.getWidth(revenueItem.revenue))
                      .backgroundColor('#64BB5C')
                      .height('100%')
                      .padding({ left: 8, right: 8 })
                    }
                  }
                  .width('100%')
                  .height(28)
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                }
                .width('100%')
                .margin({ bottom: 8 })
              }, (item: IRevenueItem[]) => JSON.stringify(item))
            }
            .backgroundColor(Color.White)
            .padding({ left: 16, top: 16, bottom: 8 })
          }

        }
      }
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('收益明细')
  }
}