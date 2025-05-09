import { ProductInfoVM } from '../../viewModels/ProductInfoVM'
import { CommonTextVisibility } from 'componentlib';

@ComponentV2
export struct ProductIntroduction {
  vm: ProductInfoVM = ProductInfoVM.instance

  @Styles
  tipStyles(){
    .padding({
      top: 1,
      bottom: 1,
      left: 4,
      right: 4
    })
    .margin({ right: 8 })
    .borderRadius(4)
    .backgroundColor('rgba(0,0,0,0.05)')
  }

  build() {
    Column() {
      Text(this.vm.productInfo.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 2 })
        .fontColor($r('sys.color.font_primary'))
      Row() {
        Text(this.vm.productInfo.number)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .margin({ right: 8 })
          .fontColor($r('sys.color.font_secondary'))
        Row() {
          Text(this.vm.productInfo.tip)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor('#C15F2F')
        }
        .padding({
          top: 1,
          bottom: 1,
          left: 6,
          right: 6
        })
        .borderRadius(4)
        .borderWidth(1)
        .borderColor('#C15F2F')
      }
      .margin({ bottom: 13 })

      Flex() {
        Row() {
          Text(this.vm.productInfo.annualizedRate + '%')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#C15F2F')
        }
        .width('37.5%')

        Row() {
          Text(this.vm.productInfo.redemptionCycle)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
        .flexGrow(1)
      }
      .margin({ bottom: 4 })

      Flex() {
        Row() {
          Text(this.vm.productInfo.annualizedCycle)
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width('37.5%')

        Row() {
          Text(this.vm.productInfo?.isRedemptionOperation)
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .flexGrow(1)
      }
      .margin({ bottom: 16 })

      Row() {
        Row() {
          Text(this.vm.productInfo.minimumPurchaseAmount + '元起购')
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
        }
        .tipStyles()

        Row() {
          Text(this.vm.productInfo.risk)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
        }
        .tipStyles()

        Row() {
          Text(this.vm.productInfo.isPurchaseAmount)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
        }
        .tipStyles()
      }
      .margin({ bottom: 12 })

      CommonTextVisibility({ description: this.vm.productInfo.performanceExplanation })
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