import { FormatUtil, RouterMap } from 'commonlib'
import { IPositionItem } from 'network/src/main/ets/types/responseTypes/GetPositionListResp'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct PositionList {
  vm: MinePageVM = MinePageVM.instance

  build() {
    Column() {
      Row() {
        Text('全部理财')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (!this.vm.isLogin) {
        Column() {
          Image($r('app.media.ic_empty'))
            .width(80)
            .height(80)
          Text('请登录后查看')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
      } else {
        if (this.vm.positionList.length === 0) {
          Text('您未购买理财产品，持仓空空如也')
        } else {
          ForEach(this.vm.positionList, (positionItem: IPositionItem, index: number) => {
            Column() {
              Row() {
                Text(positionItem.productName)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .margin({ bottom: 10 })

              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                Column() {
                  Text(positionItem.transactionAmount.toString())
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ bottom: 6 })
                  Text('持仓金额')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Text(positionItem.revenue ? positionItem.revenue.toString() : '0')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ bottom: 6 })
                  Text(`持仓收益(${positionItem.revenueDate})`)
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                }

                Column() {
                  Text(positionItem.redemptionTime)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ bottom: 6 })
                  Text() {
                    if (positionItem.isRedemption) {
                      Span('可申赎')
                    } else {
                      Span('不可申赎')
                    }
                  }
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
                }
                .alignItems(HorizontalAlign.End)
                .justifyContent(FlexAlign.Center)
              }
              .margin({ bottom: 11 })

              if (this.vm.positionList.length - 1 !== index) {
                Divider().color($r('sys.color.comp_divider'))
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 8 })
            .backgroundColor(Color.White)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.POSITION_INFO, positionItem.id)
            })
            .margin(this.vm.positionList.length - 1 !== index ? { bottom: 11 } : {})
          }, (item: IPositionItem[]) => JSON.stringify(item))
        }
      }
    }
    .padding({
      top: 12,
      bottom: 16,
      left: 12,
      right: 12
    })
    .constraintSize({ minHeight: 270 })
    .margin({ top: 12, bottom: 30 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}