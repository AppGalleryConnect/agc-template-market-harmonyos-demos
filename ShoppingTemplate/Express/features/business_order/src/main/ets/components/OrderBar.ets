import { CommonUtil } from 'module_base'
import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM'

@ComponentV2
export struct OrderBar {
  vm: OrderInfoPageVM = OrderInfoPageVM.instance

  build() {
    Column() {
      Row() {
        Text() {
          Span(this.vm.orderInfo?.companyName)
          Span('：')
          Span(this.vm.orderInfo?.orderNo)
        }
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_primary'))
        .margin({ right: 4 })

        Image($r('app.media.ic_duplicating'))
          .width(14)
          .height(14)
          .onClick(() => {
            if (this.vm.orderInfo?.orderNo) {
              CommonUtil.copyText(this.vm.orderInfo.orderNo)
            }
          })
      }
      .width('100%')
      .height(30)
      .padding({ left: 12, right: 12 })
      .borderRadius({ topLeft: 16, topRight: 16 })
      .backgroundImage($r('app.media.info_bar'))
      .backgroundImageSize(ImageSize.FILL)

      Flex() {
        Column() {
          Text(this.vm.orderInfo?.expressStatus)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ bottom: 8 })
          Text() {
            Span(this.vm.orderInfo?.expressStatus)
            Span('：')
            Span(this.vm.orderInfo?.time)
          }
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        }
        .width(138)
        .height('100%')
        .flexShrink(0)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius({ bottomLeft: 16 })

        Row() {
          Text(this.vm.orderInfo?.sendPosition)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Image($r('app.media.ic_go'))
            .width(18)
            .height(18)
            .margin({ left: 20, right: 20 })
          Text(this.vm.orderInfo?.getPosition)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
        .flexGrow(1)
        .height('100%')
        .padding({ left: 12, right: 12 })
        .backgroundColor('#F1F3F5')
        .borderRadius({ bottomRight: 16 })
      }
      .width('100%')
      .height(70)
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    }
    .padding({ left: 16, right: 16 })
    .margin({ top: 8 })
  }
}