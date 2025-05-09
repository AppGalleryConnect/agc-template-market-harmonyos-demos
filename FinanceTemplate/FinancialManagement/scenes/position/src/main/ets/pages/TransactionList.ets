import { RouterMap } from 'commonlib/src/main/ets/constants/CommonEnum'
import {
  IMonthTransactionItem,
  ITransactionItem
} from 'network/src/main/ets/types/responseTypes/GetTransactionRecordListResp'
import { TransactionListVM } from '../viewModels/TransactionListVM'
import { CustomContentDialog } from '@kit.ArkUI'
import { FormatUtil } from 'commonlib'
import { CommonFilter } from 'componentlib'


@ComponentV2
struct TransactionRecordList {
  vm: TransactionListVM = TransactionListVM.instance
  searchController: SearchController = new SearchController()
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0
    },
    alignment: DialogAlignment.Bottom,
  })

  build() {
    NavDestination() {
      Column() {
        Row() {
          Search({ value: this.vm.searchText, placeholder: '搜索', controller: this.searchController })
            .width('100%')
            .height(40)
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 16, weight: FontWeight.Regular })
            .textFont({ size: 16, weight: FontWeight.Regular })
            .margin({ bottom: 16 })
            .focusable(false)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.TRANSACTION_SEARCH)
            })
        }
        .padding({ left: 16, right: 16 })

        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Select(this.vm.selectTransactionTypeList)
              .value(this.vm.getLabel(this.vm.transactionTypeList, this.vm.transactionType))
              .font({ size: 14, weight: FontWeight.Regular })
              .backgroundColor($r('sys.color.background_secondary'))
              .onSelect((index: number, value: string) => {
                const arrangement = this.vm.getValue(this.vm.transactionTypeList, value)
                if (this.vm.transactionType !== arrangement) {
                  this.vm.transactionType = arrangement
                  this.vm.search()
                }
              })
            Select(this.vm.selectTransactionDateList)
              .value(this.vm.getLabel(this.vm.transactionDateList, this.vm.transactionDate))
              .font({ size: 14, weight: FontWeight.Regular })
              .backgroundColor($r('sys.color.background_secondary'))
              .onSelect((index: number, value: string) => {
                const arrangement = this.vm.getValue(this.vm.transactionDateList, value)
                if (this.vm.transactionDate !== arrangement) {
                  this.vm.transactionDate = arrangement
                  this.vm.search()
                }
              })
          }

          Row() {
            Text('筛选')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.vm.isSelecting ? '#E4480C' : $r('sys.color.font_primary'))
            Image(this.vm.isSelecting ? $r('app.media.ic_select_filter') : $r('app.media.ic_filter'))
              .width(16)
              .height(16)
          }
          .onClick(() => {
            this.dialogController.open()
          })
        }
        .padding({ left: 16, right: 16 })

        if (this.vm.transactionRecordList.length <= 0) {
          Column() {
            Image($r('app.media.ic_no_record'))
              .width(120)
              .height(120)
            Text('暂无交易记录')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')
          .margin({ top: 77 })
        } else {
          List() {
            ForEach(this.vm.transactionRecordList, (monthTransactionItem: IMonthTransactionItem) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(monthTransactionItem.month)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16 })
                  .margin({ bottom: 8 })

                  ForEach(monthTransactionItem.transactionList, (transactionItem: ITransactionItem) => {
                    Flex() {
                      Row() {
                        Text() {
                          if (transactionItem.type === 2) {
                            Span('购买')
                              .fontColor('#E4480C')
                          } else if (transactionItem.type === 3) {
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
                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
                          Text(transactionItem.productName)
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ right: 20 })
                          Text(transactionItem.amount + '元')
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                        }
                        .height(38)
                        .margin({ bottom: 2 })

                        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                          Text(transactionItem.date)
                            .fontSize(12)
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'))
                          Text('份额为' + transactionItem.share + '份')
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
                      FormatUtil.jumpToNext(RouterMap.TRANSACTION_RECORD_INFO, transactionItem.id)
                    })
                  }, (monthTransactionItem: IMonthTransactionItem[]) => JSON.stringify(monthTransactionItem))
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .margin({ top: 10 })
            }, (item: IMonthTransactionItem[]) => JSON.stringify(item))
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('交易记录')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('筛选')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.ic_close'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.dialogController.close()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .margin({ bottom: 33 })

          Row() {
            CommonFilter({
              text: '销售状态类型',
              value: this.vm.transactionType,
              list: this.vm.transactionTypeList,
              changeValue: (value) => {
                this.vm.transactionType = value
              }
            })
          }
          .margin({ bottom: 11 })

          CommonFilter({
            text: '销售周期',
            value: this.vm.transactionDate,
            list: this.vm.transactionDateList,
            changeValue: (value) => {
              this.vm.transactionDate = value
            }
          })

          Row() {
            Row() {
              Button('重置')
                .width('100%')
                .height(40)
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
            }
            .width('calc(50% - 6vp)')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .margin({ right: 12 })
            .onClick(() => {
              this.vm.isSelecting = false
              this.vm.reset()
              this.dialogController.close()
            })

            Row() {
              Button('完成')
                .width('100%')
                .height(40)
                .fontColor(Color.White)
                .backgroundColor('#E4480C')
            }
            .width('calc(50% - 6vp)')
            .height(40)
            .onClick(async () => {
              this.vm.isSelecting = true
              this.vm.search()
              this.dialogController.close()
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
    }
  }
}

@Builder
export function TransactionRecordListBuilder() {
  TransactionRecordList()
}