import { FormatUtil, RouterMap } from 'commonlib'
import { CommonTextVisibility } from 'componentlib/src/main/ets/components/CommonTextVisibility'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { ProductListVM } from '../../viewModels/ProductListVM'
import { CustomContentDialog } from '@kit.ArkUI'
import { ISettingData } from 'network/src/main/ets/mocks/Constants'
import { CommonFilter } from 'componentlib'

@ComponentV2
export struct CustomTabContent {
  vm: ProductListVM = ProductListVM.instance
  @Local index: number = 2
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
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Select(this.vm.selectArrangementList)
            .value(this.vm.getLabel(this.vm.arrangementList, this.vm.arrangement))
            .font({ size: 14, weight: FontWeight.Regular })
            .backgroundColor($r('sys.color.background_secondary'))
            .onSelect((index: number, value: string) => {
              const arrangement = this.vm.getValue(this.vm.arrangementList, value)
              if (this.vm.arrangement !== arrangement) {
                this.vm.arrangement = arrangement
                this.vm.search()
              }
            })
          Select(this.vm.selectSaleTypeList)
            .value(this.vm.getLabel(this.vm.saleTypeList, this.vm.saleType))
            .font({ size: 14, weight: FontWeight.Regular })
            .backgroundColor($r('sys.color.background_secondary'))
            .onSelect((index: number, value: string) => {
              const saleType = this.vm.getValue(this.vm.saleTypeList, value)
              if (this.vm.saleType !== saleType) {
                this.vm.saleType = saleType
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

      List() {
        ForEach(this.vm.productList, (product: IProductItem, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(product.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              }
              .margin({ bottom: 3 })

              Row() {
                Row() {
                  Text(product.tip)
                    .fontColor('#C15F2F')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                }
                .padding({
                  left: 5,
                  right: 5,
                  top: 1,
                  bottom: 1
                })
                .borderRadius(4)
                .borderWidth(1)
                .borderColor('#C15F2F')
                .margin({ right: 8 })

                Row() {
                  Text(this.vm.getProductSaleType(product.saleType))
                    .fontColor('#C15F2F')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                }
                .padding({
                  left: 5,
                  right: 5,
                  top: 1,
                  bottom: 1
                })
                .borderRadius(4)
                .borderWidth(1)
                .borderColor('#C15F2F')
              }
              .margin({ bottom: 14 })

              Flex() {
                Row() {
                  Text(product.annualizedRate + '%')
                    .fontSize(20)
                    .fontColor('#C15F2F')
                    .fontWeight(FontWeight.Medium)
                }
                .width('40%')

                Row() {
                  Text(product.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
                .flexGrow(1)
              }
              .margin({ bottom: 4 })

              Flex() {
                Row() {
                  Text(product.annualizedCycle)
                    .fontSize(12)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .width('40%')

                Row() {
                  Text() {
                    Span(product.risk)
                    Span(' | ')
                    Span(product.minimumPurchaseAmount + '元起购')
                  }
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
                }
                .flexGrow(1)
              }
              .margin({ bottom: 7 })

              CommonTextVisibility({ description: product.performanceExplanation })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .padding({
            top: 16,
            bottom: 12,
            left: 12,
            right: 12
          })
          .margin(this.vm.productList.length - 1 !== index ? { bottom: 12 } : {})
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
          })
        }, (item: IProductItem[]) => JSON.stringify(item))
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
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
            text: '销售状态',
            value: this.vm.saleType,
            list: this.vm.saleTypeList,
            changeValue: (value) => {
              this.vm.saleType = value
            }
          })
        }
        .margin({ bottom: 11 })

        Row() {
          CommonFilter({
            text: '起购金额',
            value: this.vm.minimumPurchaseAmount,
            list: this.vm.minimumPurchaseAmountList,
            changeValue: (value) => {
              this.vm.minimumPurchaseAmount = value
            }
          })
        }
        .margin({ bottom: 11 })

        CommonFilter({
          text: '风险等级',
          value: this.vm.riskLevel,
          list: this.vm.riskLevelList,
          changeValue: (value) => {
            this.vm.riskLevel = value
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
            this.vm.filter()
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