import { FormatUtil, RouterMap } from 'commonlib'
import { IRegularInvestmentItem } from 'network/src/main/ets/types/responseTypes/GetRegularInvestmentResp'
import { MyRegularInvestmentVM } from '../viewModels/MyRegularInvestmentVM'

@Builder
export function MyRegularInvestmentBuilder() {
  MyRegularInvestment()
}

@ComponentV2
struct MyRegularInvestment {
  vm: MyRegularInvestmentVM = MyRegularInvestmentVM.instance

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.regularInvestmentList.length === 0) {
          Text('您目前没有已定投的理财产品哦~')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        } else {
          List() {
            ForEach(this.vm.regularInvestmentList, (item: IRegularInvestmentItem) => {
              ListItem() {
                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text(item.productName + `(${item.productNumber})`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                    Row() {
                      Text(FormatUtil.getStateTitle(item.state))
                        .fontSize(10)
                        .fontWeight(FontWeight.Regular)
                        .fontColor(FormatUtil.getStateFontColor(item.state))
                    }
                    .padding({
                      top: 1,
                      bottom: 1,
                      left: 4,
                      right: 4
                    })
                    .backgroundColor('rgba(193,95,47,0.10)')
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
                    Text(item.amount + '')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                    Text(item.times + '')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                  }
                }
                .padding({
                  top: 16,
                  bottom: 16,
                  left: 12,
                  right: 12
                })
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .borderRadius(16)
              }
              .margin({ bottom: 12 })
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.MY_REGULAR_INVESTMENT_INFO, item.id)
              })
            }, (item: IRegularInvestmentItem[]) => JSON.stringify(item))
          }
          .layoutWeight(1)
        }
      }
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 })
    }
    .title('我的定投')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}