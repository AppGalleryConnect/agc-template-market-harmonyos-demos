import { Formatter, RouterMap, routerStack } from 'lib_foundation'
import { OrderItem, RedemptionOrder } from 'lib_network'
import { CommonLoading, CommonScroll, ContainerColumn, CustomServiceSheet } from 'lib_widget'
import { RedemptionOrderStatus } from '../commons/Enums'
import { RedemptionInfoVM } from '../viewmodels/RedemptionInfoVM'
import { PointsUtil } from '../utils/PointsUtil'
import { buildPointsAddressSheetOptions } from '../utils/PointsAddressUtil'

@Builder
export function buildRedemptionInfoPage() {
  RedemptionInfoPage()
}

@ComponentV2
struct RedemptionInfoPage {
  vm: RedemptionInfoVM = new RedemptionInfoVM()

  build() {
    NavDestination() {
      CommonScroll({ bgColor: $r('app.color.background_color_grey') }) {
        if (this.vm.isLoading) {
          CommonLoading()
        } else {
          if (this.vm.order) {
            Column() {
              this.buildStatusBlock(this.vm.order)
              this.buildAddressCard(this.vm.order)
              this.buildProductCard(this.vm.order)
              this.buildPriceCard(this.vm.order)
              this.buildOrderInfoCard(this.vm.order)
            }
          }
        }
      }

      if (!this.vm.isLoading && this.vm.order) {
        this.buildBottomBar(this.vm.order)
      }
    }
    .title('兑换详情')
    .onReady((context) => {
      const orderId = context.pathInfo.param as string
      this.vm.loadDetail(orderId)
    })
  }

  @Builder
  buildStatusBlock(order: RedemptionOrder) {
    Column() {
      Text(PointsUtil.getStatusLabel(order.status))
        .fontSize($r('app.float.font_size_24'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'))
    }
    .width($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: $r('app.float.space_l'),
      bottom: $r('app.float.space_l'),
    })
  }

  @Builder
  buildAddressCard(order: RedemptionOrder) {
    ContainerColumn() {
      // 物流状态行（待收货 + 有物流信息时显示，与订单详情地址卡片一致）
      if (order.status === RedemptionOrderStatus.PENDING_RECEIPT &&
      order.logisticInfo && order.logisticInfo.length > 0) {
        Row({ space: 8 }) {
          Image(order.logisticInfo[0].icon)
            .width(16)
            .height(16)
            .fillColor($r('app.color.theme_color'))
          Text(PointsUtil.getLogisticStatusLabel(order.logisticInfo[0].status))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.theme_color'))
          Text(order.logisticInfo[0].details[0]?.desc ?? '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Image($r('app.media.ic_arrow_right'))
            .width(16)
            .height(16)
        }
        .onClick(() => {
          this.navigateToExpress(order)
        })

        Divider().margin({ top: 12, bottom: 12 })
      }

      Row({ space: 12 }) {
        Image($r('app.media.ic_address'))
          .width(20)
          .height(20)
        Row() {
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(order.addressInfo.name)
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('app.color.font_color_level1'))
                .fontWeight(FontWeight.Medium)
              Text(order.addressInfo.cellphone)
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('app.color.font_color_level1'))
            }

            Text(order.addressInfo.address)
              .fontSize($r('app.float.font_size_14'))
              .fontColor($r('app.color.font_color_level2'))
              .width($r('app.string.size_percent_full'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (order.status === RedemptionOrderStatus.PENDING_SHIPMENT) {
            Text('修改')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.theme_color'))
              .onClick(() => {
                this.openAddressSheet(order)
              })
          }
        }
        .layoutWeight(1)
      }
      .width($r('app.string.size_percent_full'))
      .alignItems(VerticalAlign.Top)
    }
  }

  @Builder
  buildProductCard(order: RedemptionOrder) {
    ContainerColumn() {
      // 商品行：Image + 左侧标题列 + 右侧价格/数量列（与 buildOrderBaseInfoCard 对齐）
      Row({ space: 12 }) {
        Image(order.product.banner)
          .width(80)
          .aspectRatio(1)
          .borderRadius($r('app.float.border_radius_s'))
          .objectFit(ImageFit.Cover)

        Column({ space: 4 }) {
          Text(order.product.title)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text() {
            Span(order.product.price.toString())
            Span(' 积分').fontSize($r('app.float.font_size_12'))
          }
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)

          Text('x1')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
        }
        .alignItems(HorizontalAlign.End)
      }
      .alignItems(VerticalAlign.Top)
      .width($r('app.string.size_percent_full'))

      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({
          top: $r('app.float.space_l'),
          bottom: $r('app.float.space_l'),
        })

      // 联系客服行（与订单详情一致）
      Row() {
        SymbolGlyph($r('sys.symbol.service'))
          .fontColor([$r('app.color.font_color_level2')])
          .margin({ right: $r('app.float.space_s') })
        Text('联系客服')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('sys.color.font_primary'))
      }
      .onClick(() => {
        CustomServiceSheet.show()
      })
    }
  }

  @Builder
  buildPriceCard(order: RedemptionOrder) {
    ContainerColumn() {
      Column({ space: 12 }) {
        Row() {
          Text('商品积分')
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
          Blank()
          Text(`${order.product.price} 积分`)
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
        }
        .width($r('app.string.size_percent_full'))

        Row() {
          Text('实付积分')
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
          Blank()
          Text(`${order.product.price} 积分`)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1'))
        }
        .width($r('app.string.size_percent_full'))
      }
      .margin({
        top: $r('app.float.space_xs'),
        bottom: $r('app.float.space_xs'),
      })
    }
  }

  @Builder
  buildOrderInfoCard(order: RedemptionOrder) {
    ContainerColumn() {
      Text('订单信息')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .width($r('app.string.size_percent_full'))
      Column({ space: 12 }) {
        this.buildInfoRow('订单编号', order.orderId, true)
        this.buildInfoRow('兑换时间', Formatter.formatFullDate(new Date(order.orderTime)))
        this.buildInfoRow('配送方式', '快递发货')
      }
    }
  }

  @Builder
  buildInfoRow(label: string, value: string, copyable: boolean = false,
    valueColor: ResourceColor = $r('app.color.font_color_level1')) {
    Row() {
      Text(label)
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level2'))
      Blank()
      Row({ space: 4 }) {
        Text(value)
          .fontSize($r('app.float.font_size_12'))
          .fontColor(valueColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 200 })
        if (copyable) {
          Text('复制')
            .fontSize($r('app.float.font_size_10'))
            .borderWidth(1)
            .borderColor($r('app.color.theme_color'))
            .fontColor($r('app.color.theme_color'))
            .borderRadius($r('app.float.border_radius_capsule'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .backgroundColor($r('app.color.background_color_primary'))
            .onClick(() => {
              PointsUtil.copyText(value)
            })
        }
      }
    }
    .width($r('app.string.size_percent_full'))
  }

  @Builder
  buildBottomBar(order: RedemptionOrder) {
    Row({ space: 12 }) {
      Blank()
      if (order.status === RedemptionOrderStatus.PENDING_SHIPMENT) {
        Button('催发货')
          .type(ButtonType.Normal)
          .borderRadius(20)
          .backgroundColor($r('app.color.theme_color'))
          .onClick(() => {
            this.vm.urgeShipment()
          })
      } else if (order.status === RedemptionOrderStatus.PENDING_RECEIPT) {
        Button('确认收货')
          .type(ButtonType.Normal)
          .borderRadius(20)
          .backgroundColor($r('app.color.theme_color'))
          .onClick(() => {
            AlertDialog.show({
              title: '确认收货',
              message: '确认已收到商品？',
              primaryButton: {
                value: '取消',
                action: () => {
                },
              },
              secondaryButton: {
                value: '确认',
                fontColor: $r('app.color.theme_color'),
                action: () => {
                  this.vm.confirmReceipt()
                },
              },
            })
          })
      } else if (order.status === RedemptionOrderStatus.COMPLETED) {
        Button('删除订单')
          .backgroundColor($r('app.color.background_color_button_grey'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            AlertDialog.show({
              title: '删除订单',
              message: '确认删除该兑换记录？',
              primaryButton: {
                value: '取消',
                action: () => {
                },
              },
              secondaryButton: {
                value: '删除',
                fontColor: $r('app.color.theme_color'),
                action: () => {
                  this.vm.deleteOrder()
                },
              },
            })
          })
      }
    }
    .width($r('app.string.size_percent_full'))
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private navigateToExpress(order: RedemptionOrder): void {
    const orderItemParam: OrderItem = {
      orderInfo: {
        status: 3,
        orderNo: order.orderId,
        addressInfo: order.addressInfo,
        orderTime: order.orderTime,
        originalPrice: order.product.price,
        finalPrice: order.product.price,
        discounts: [],
        receivingMethod: 1,
      },
      logisticInfo: order.logisticInfo ?? [],
      skuInfo: [],
    }
    routerStack.pushPath({ name: RouterMap.POINTS_EXPRESS_INFO, param: orderItemParam })
  }

  private openAddressSheet(order: RedemptionOrder): void {
    const options = buildPointsAddressSheetOptions({
      originalAddress: order.addressInfo,
      orderId: order.orderId,
      handleSubmitSuccess: () => {
        this.vm.loadDetail(order.orderId)
      },
    })
    routerStack.pushPath({
      name: RouterMap.UPDATE_ADDRESS,
      param: options,
    })
  }
}
