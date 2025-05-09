import { FormatUtil, RouterMap } from 'commonlib'
import { ITransactionItem } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordListResp'
import { TransactionSearchVM } from '../viewModels/TransactionSearchVM'

@Builder
export function TransactionSearchBuilder() {
  TransactionSearch()
}

@ComponentV2
struct TransactionSearch {
  vm: TransactionSearchVM = TransactionSearchVM.instance
  searchController: SearchController = new SearchController()

  build() {
    NavDestination() {
      Column() {
        Row() {
          Search({ value: this.vm.searchText, placeholder: '请输入产品名称/代码', controller: this.searchController })
            .width('100%')
            .height(40)
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: 16, weight: FontWeight.Regular })
            .textFont({ size: 16, weight: FontWeight.Regular })
            .fontColor($r('sys.color.font_primary'))
            .onSubmit((value: string) => {
              this.vm.search(value)
            })
        }
        .padding({ left: 16, right: 16 })

        Row() {
          Text(`共款${this.vm.transactionList.length}产品`)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .padding({ left: 16, right: 16 })
        .margin({ top: 16, bottom: 8 })

        List() {
          ForEach(this.vm.transactionList, (transaction: ITransactionItem) => {
            ListItem() {
              Flex() {
                Row() {
                  Text() {
                    if (transaction.type === 2) {
                      Span('购买')
                        .fontColor('#E4480C')
                    } else if (transaction.type === 3) {
                      Span('赎回')
                    } else {
                      Span('到期')
                    }
                  }
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                }
                .margin({ right: 8 })
                .flexShrink(0)

                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text(transaction.productName)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 20 })
                    Text(transaction.amount + '元')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .margin({ bottom: 20 })

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text(transaction.date)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                    Text('份额为' + transaction.share + '份')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                }
                .flexGrow(1)
              }
              .backgroundColor(Color.White)
              .padding({
                top: 12,
                bottom: 12,
                left: 16,
                right: 16
              })
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.TRANSACTION_RECORD_INFO, transaction.id)
              })
            }
            .margin({ top: 10 })
          }, (item: ITransactionItem[]) => JSON.stringify(item))
        }
        .layoutWeight(1)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('搜索')
    .onShown(() => {
      this.vm.init()
    })
  }
}