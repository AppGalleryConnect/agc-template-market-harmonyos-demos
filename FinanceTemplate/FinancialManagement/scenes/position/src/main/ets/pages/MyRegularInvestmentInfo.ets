import { RouterMap } from 'commonlib'
import { IInvestmentRecordItem } from 'network/src/main/ets/types/responseTypes/GetRegularInvestmentResp'
import { MyRegularInvestmentInfoVM } from '../viewModels/MyRegularInvestmentInfoVM'
import { FormatUtil } from 'commonlib'


@Builder
export function MyRegularInvestmentInfoBuilder() {
  MyRegularInvestmentInfo()
}

@ComponentV2
struct MyRegularInvestmentInfo {
  vm: MyRegularInvestmentInfoVM = MyRegularInvestmentInfoVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.vm.regularInvestmentInfo) {
            Column() {
              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                Text(this.vm.regularInvestmentInfo.productName + `(${this.vm.regularInvestmentInfo.productNumber})`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Row() {
                  Text(FormatUtil.getStateTitle(this.vm.regularInvestmentInfo.state))
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(FormatUtil.getStateFontColor(this.vm.regularInvestmentInfo.state))
                }
                .padding({
                  top: 1,
                  bottom: 1,
                  left: 4,
                  right: 4
                })
                .borderRadius(4)
              }
              .margin({ bottom: 12 })

              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                Text('累计定投(元)')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
                Text('已投期数')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .margin({ bottom: 2 })

              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                Text(this.vm.regularInvestmentInfo.amount.toFixed(2) + '')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Text(this.vm.regularInvestmentInfo.times + '')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              }
              .margin({ bottom: 12 })

              Row() {
                Row()
                  .width(4)
                  .height(4)
                  .borderRadius('50%')
                  .backgroundColor($r('sys.color.icon_tertiary'))
                  .margin({ right: 4 })
                Text(`${this.vm.regularInvestmentInfo.date}定投转入 ${this.vm.regularInvestmentInfo.money}元`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .width('100%')
              .padding({
                top: 14,
                bottom: 14,
                left: 8,
                right: 8
              })
              .borderRadius(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
            }
            .padding({
              top: 16,
              bottom: 16,
              left: 12,
              right: 12
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)
            .margin({ bottom: 12 })

            Column() {
              Row() {
                Text('定投记录')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))
              }
              .width('100%')
              .margin({ top: 8, bottom: 8 })

              ForEach(this.vm.investmentRecordList, (item: IInvestmentRecordItem, index: number) => {
                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Row() {
                      Text(item.date)
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                        .margin({ right: 16 })
                      Text(item.money.toFixed(2) + '元')
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                    }

                    Row() {
                      Text(FormatUtil.getStateTitle(item.state))
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .margin({ right: 2 })
                        .fontColor(item.state === 3 ? '#E84026' : $r('sys.color.font_primary'))
                      Image($r('app.media.icc_arrow_right'))
                        .width(12)
                        .height(12)
                    }
                    .onClick(() => {
                      FormatUtil.jumpToNext(RouterMap.INVESTMENT_RECORD_INFO,
                        { investmentInfo: this.vm.regularInvestmentInfo, record: item })
                    })
                  }
                  .padding({ top: 11, bottom: 11 })

                  if (this.vm.investmentRecordList.length - 1 !== index) {
                    Divider().color($r('sys.color.comp_divider'))
                  }
                }
              }, (item: IInvestmentRecordItem[]) => JSON.stringify(item))

            }
            .padding({
              top: 16,
              bottom: 6,
              left: 12,
              right: 12
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)
            .margin({ bottom: 12 })
          }
        }
        .margin({ top: 8 })
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
    }
    .title('定投详情')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }
}