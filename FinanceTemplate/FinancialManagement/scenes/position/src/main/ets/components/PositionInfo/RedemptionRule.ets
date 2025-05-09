import { FormatUtil, RouterMap } from 'commonlib'
import { PositionInfoVM } from '../../viewModels/PositionInfoVM'


@ComponentV2
export struct RedemptionRule {
  vm: PositionInfoVM = PositionInfoVM.instance

  @Builder
  contentBuilder(text: string) {
    Text(text)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
    Row()
      .width(1)
      .height(10)
      .backgroundColor('#E4480C')
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('赎回规则')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          Text('更多')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: 5 })
          Image($r('app.media.icc_arrow_right'))
            .width(12)
            .height(24)
        }
        .onClick(() => {
          FormatUtil.jumpToNext(RouterMap.RULE, { id: this.vm.positionInfo?.productId, index: 1 })
        })
      }
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(this.vm.positionInfo?.redemptionApplicationDate)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
          this.contentBuilder('赎回日')
          Row()
            .width('100%')
            .height(10)
            .backgroundColor('#E4480C')
            .opacity(0.1)
        }
        .width('30%')
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 1 })

        Column() {
          Flex({ alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween }) {
            Column() {
              Text(this.vm.positionInfo?.redemptionApplicationConfirmDate)
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
              this.contentBuilder('确认日')
            }
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text(this.vm.positionInfo?.fundsReceivedDate)
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
              this.contentBuilder('到账日')
            }
            .alignItems(HorizontalAlign.End)
          }

          Row()
            .width('100%')
            .height(10)
            .backgroundColor('#E4480C')
            .opacity(0.1)
        }
        .width('70%')
        .alignItems(HorizontalAlign.Start)
      }
      .margin({ bottom: 10 })

      Row() {
        Row()
          .width(4)
          .height(4)
          .backgroundColor($r('sys.color.icon_tertiary'))
          .borderRadius('50%')
          .margin({ left: 8, right: 4 })
        Text(this.vm.positionInfo?.redemptionTip)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(32)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(8)
    }
    .backgroundColor(Color.White)
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
}