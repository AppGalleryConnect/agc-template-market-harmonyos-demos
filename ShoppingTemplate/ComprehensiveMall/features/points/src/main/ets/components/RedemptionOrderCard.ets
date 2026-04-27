import { Formatter } from 'lib_foundation'
import { RedemptionOrder } from 'lib_network'
import { ContainerColumn } from 'lib_widget'
import { RedemptionOrderStatus } from '../commons/Enums'
import { PointsUtil } from '../utils/PointsUtil'

@ComponentV2
export struct RedemptionOrderCard {
  @Param @Require order: RedemptionOrder
  @Event onClickCard: () => void = () => {}
  @Event onModifyAddress: () => void = () => {}
  @Event onUrge: () => void = () => {}
  @Event onConfirmReceipt: () => void = () => {}
  @Event onDelete: () => void = () => {}
  @Event onViewExpress: () => void = () => {}

  build() {
    ContainerColumn() {
      // Header行：兑换时间 | 状态
      Row() {
        Text(Formatter.formatFullDate(new Date(this.order.orderTime)))
          .fontColor($r('app.color.font_color_level3'))
          .fontSize($r('app.float.font_size_12'))
        Text(PointsUtil.getStatusLabel(this.order.status))
          .fontColor($r('app.color.theme_color'))
          .fontSize($r('app.float.font_size_14'))
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.space_l') })

      // 商品信息行：Image + 左侧标题列(layoutWeight) + 右侧价格/数量列(alignEnd)
      Row({ space: 12 }) {
        Image(this.order.product.banner)
          .width(60)
          .height(60)
          .borderRadius($r('app.float.border_radius_s'))
          .objectFit(ImageFit.Cover)

        Column({ space: 4 }) {
          Text(this.order.product.title)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text() {
            Span(this.order.product.price.toString())
            Span(' 积分').fontSize($r('app.float.font_size_12'))
          }
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)

          Text('x1')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
        }
        .width(64)
        .alignItems(HorizontalAlign.End)
      }
      .width($r('app.string.size_percent_full'))
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: $r('app.float.space_l') })
      .onClick(() => {
        this.onClickCard()
      })

      // 物流信息行（待收货 + 有物流信息时显示，样式与订单列表一致）
      if (this.order.status !== RedemptionOrderStatus.COMPLETED &&
        this.order.logisticInfo && this.order.logisticInfo.length > 0) {
        Row({ space: 8 }) {
          Image(this.order.logisticInfo[0].icon)
            .width(16)
            .height(16)
            .fillColor($r('app.color.font_color_level1'))
          Text(PointsUtil.getLogisticStatusLabel(this.order.logisticInfo[0].status))
            .fontSize($r('app.float.font_size_12'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1'))
          Divider().vertical(true).height(12)
          Text(this.order.logisticInfo[0].details[0]?.desc ?? '')
            .fontSize($r('app.float.font_size_12'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level2'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if(this.order.status === RedemptionOrderStatus.PENDING_RECEIPT){
            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
          }
        }
        .width($r('app.string.size_percent_full'))
        .padding($r('app.float.space_m'))
        .backgroundColor($r('app.color.background_color_grey'))
        .borderRadius($r('app.float.border_radius_s'))
        .margin({ bottom: $r('app.float.space_l') })
        .onClick(() => {
          this.onViewExpress()
        })
      }

      // 操作按钮行（样式与订单列表一致）
      Row({ space: 8 }) {
        Blank()
        if (this.order.status === RedemptionOrderStatus.PENDING_SHIPMENT) {
          Button('修改地址')
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('app.color.background_color_button_grey'))
            .fontColor($r('app.color.theme_color'))
            .onClick(() => {
              this.onModifyAddress()
            })

          Button('催发货')
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('app.color.theme_color'))
            .onClick(() => {
              this.onUrge()
            })
        } else if (this.order.status === RedemptionOrderStatus.PENDING_RECEIPT) {
          Button('确认收货')
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('app.color.theme_color'))
            .onClick(() => {
              this.onConfirmReceipt()
            })
        } else if (this.order.status === RedemptionOrderStatus.COMPLETED) {
          Button('删除订单')
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('app.color.background_color_button_grey'))
            .fontColor($r('sys.color.font_primary'))
            .onClick(() => {
              this.onDelete()
            })
        }
      }
      .width($r('app.string.size_percent_full'))
    }
  }
}
