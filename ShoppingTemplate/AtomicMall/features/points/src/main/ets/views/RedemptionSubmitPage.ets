import { routerStack } from 'lib_foundation'
import { ContainerColumn, NavTitleBar } from 'lib_widget'
import { UserPointRedemptionSku } from 'lib_network'
import { AddressManageUtil } from 'address_management'
import { RedemptionSubmitVM } from '../viewmodels/RedemptionSubmitVM'

@Builder
export function buildRedemptionSubmitPage() {
  RedemptionSubmitPage()
}

@ComponentV2
struct RedemptionSubmitPage {
  vm: RedemptionSubmitVM = new RedemptionSubmitVM()

  build() {
    NavDestination() {
      NavTitleBar({
        title: '确认订单',
        titleColor: $r('app.color.font_color_level1_invert'),
      })
      Scroll() {
        Column() {
          this.buildShippingInfo()
          if (this.vm.product) {
            this.buildProductInfo(this.vm.product)
          }
        }
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding(16)

      this.buildBottomBar()
    }
    .hideTitleBar(true)
    .linearGradient({
      colors: [[0xFFE64566, 0.1], [0x00f1f3f5, 0.5]],
    })
    .onReady((context) => {
      this.vm.product = context.pathInfo.param as UserPointRedemptionSku | undefined
      this.vm.init()
    })
  }

  @Builder
  buildShippingInfo() {
    ContainerColumn() {
      Row() {
        Image($r('app.media.ic_address'))
          .width(24)
          .margin({ right: 16 })
        Row() {
          Column() {
            Text(this.vm.displayAddress)
              .fontColor($r('app.color.font_color_level1'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: 2 })
            Text(this.vm.displayCustomerInfo)
              .fontColor($r('app.color.font_color_level3'))
              .fontSize($r('app.float.font_size_14'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .margin({ right: 16 })
          .alignItems(HorizontalAlign.Start)

          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .arrowStyle()
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .onClick(() => {
        AddressManageUtil.goToAddressListPage(routerStack.getActiveStack(), (data) => {
          this.vm.customerAddress = data.province + data.city + data.district + data.street + data.detail
          this.vm.customerName = data.name
          this.vm.customerPhone = data.phone
        })
      })
    }
  }

  @Builder
  buildProductInfo(product: UserPointRedemptionSku) {
    ContainerColumn() {
      Row({ space: 12 }) {
        Image(product.banner)
          .width(96)
          .aspectRatio(1)
          .borderRadius($r('app.float.border_radius_s'))
        Column({ space: 8 }) {
          Text(product.title)
            .fontColor($r('app.color.font_color_level1'))
            .fontSize(14)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text('数量: 1')
            .fontSize(12)
            .fontColor($r('app.color.font_color_level2'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text() {
          Span('积分').fontSize(12)
          Span(product.price.toString()).fontSize(18).fontWeight(FontWeight.Medium)
        }
        .fontColor($r('app.color.theme_color'))
      }
      .alignItems(VerticalAlign.Top)

      this.buildInfoItem('配送服务', '快递发货')
      this.buildInfoItem('订单金额', product.price + '积分')
    }
  }

  @Builder
  buildBottomBar() {
    Row() {
      Column() {
        Text() {
          Span('合计: ').fontSize(12)
          Span('¥0 +').fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.theme_color'))
          Span((this.vm.product?.price ?? 0) + '积分')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.theme_color'))
        }
        .fontColor($r('app.color.font_color_level1'))
      }
      .margin({ right: 16 })
      .alignItems(HorizontalAlign.End)

      Button('提交订单')
        .backgroundColor($r('app.color.theme_color'))
        .onClick(() => {
          this.vm.onSubmit()
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16,
    })
  }

  @Builder
  buildInfoItem(label: string, content: string) {
    Row() {
      Text(label)
        .fontColor($r('app.color.font_color_level2'))
        .fontSize(14)

      Blank().constraintSize({ minWidth: 48 })

      Text(content)
        .fontColor($r('app.color.font_color_level1'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .lineHeight(20)
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .margin({ top: 16 })
  }
}

@Extend(Image)
function arrowStyle() {
  .height(20)
  .width(20)
  .fillColor($r('app.color.font_color_level2'))
}
