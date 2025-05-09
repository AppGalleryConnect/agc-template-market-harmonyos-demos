import { FormatUtil, RouterMap } from 'commonlib'
import { PositionInfoVM } from '../../viewModels/PositionInfoVM'


@ComponentV2
export struct PositionIntroduction {
  vm: PositionInfoVM = PositionInfoVM.instance

  build() {
    Column() {
      Flex() {
        Row() {
          Text(this.vm.positionInfo?.productName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .margin({ right: 16 })
        .flexGrow(1)

        Row() {
          Text('产品详情')
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor('#C15F2F')
        }
        .width(54)
        .height(16)
        .justifyContent(FlexAlign.Center)
        .borderRadius(4)
        .backgroundColor('rgba(193,95,47,0.10)')
        .onClick(() => {
          FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, this.vm.positionInfo?.productId)
        })
      }
      .margin({ bottom: 2 })

      Text(this.vm.positionInfo?.productNumber)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 9 })

      Divider().color($r('sys.color.comp_divider')).margin({ bottom: 15 })

      Column() {
        Text('持仓市值(元)')
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ bottom: 2 })
        Text(this.vm.positionInfo?.positionAmount + '')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .margin({ bottom: 17 })


      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Text('日盈亏')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Text(this.vm.positionInfo?.dailyProfitAndLoss + '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }

        Column() {
          Text('持仓收益')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Text(this.vm.positionInfo?.positionProfit + '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }

        Column() {
          Text('累计盈亏')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Text(this.vm.positionInfo?.allProfitAndLoss + '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
      }
      .margin({ bottom: 22 })

      Row() {
        Image(this.vm.isExpand ? $r('app.media.ic_arrow_up') : $r('app.media.ic_arrow_down'))
          .width(16)
          .height(16)
          .onClick(() => {
            this.vm.isExpand = !this.vm.isExpand
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      if (this.vm.isExpand) {
        Column() {
          Flex({ wrap: FlexWrap.Wrap }) {
            this.contentBuilder('持有金额：', this.vm.positionInfo?.positionAmount + '')
            this.contentBuilder('待确认金额：', this.vm.positionInfo?.toBeConfirmedAmount + '')
            this.contentBuilder('持仓成本价：', this.vm.positionInfo?.positionCostPrice + '')
            this.contentBuilder('持有份额：', this.vm.positionInfo?.positionSize + '')
            this.contentBuilder('日涨幅：', this.vm.positionInfo?.dailyRate + '')
            Row() {
              Text() {
                Span('净值：')
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
                Span(this.vm.positionInfo?.netValue + '')
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Span('(' + this.vm.positionInfo?.payoutDate + ')')
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .fontSize(12)
            }
            .width('50%')
            .margin({ bottom: 8 })
          }
        }
        .margin({ top: 8 })
        .padding({
          top: 16,
          bottom: 8,
          left: 8,
          right: 8
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .padding({
      top: 16,
      bottom: 8,
      left: 12,
      right: 12
    })
  }

  @Builder
  contentBuilder(label: string, value: string) {
    Row() {
      Text() {
        Span(label)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        Span(value)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .fontSize(12)
    }
    .width('50%')
    .margin({ bottom: 8 })
  }
}