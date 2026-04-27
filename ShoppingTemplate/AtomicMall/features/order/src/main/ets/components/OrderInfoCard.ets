import { RouterMap, routerStack } from 'lib_foundation';
import { OrderInfo, OrderItem, OrderSkuItem } from 'lib_network';
import { OrderActionMap, OrderShipmentMap, OrderStatusMap } from '../common/Enums';
import { MyButtonModifier, OrderAction } from '../common/Types';
import { formatFullDate } from '../utils';
import { OrderUtil } from '../utils/OrderUtil';

/**
 * 订单中单个商品信息卡片
 * @param skuInfo
 */
@Builder
export function buildOrderBaseInfoCard(skuInfo: OrderSkuItem) {
  Row() {
    Image(skuInfo.banner)
      .width(60)
      .height(60)
      .borderRadius($r('app.float.border_radius_s'))
      .margin({ right: $r('app.float.space_m') })
    Column({ space: 4 }) {
      Text(skuInfo.title)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_size_14'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(skuInfo.skuDesc)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)

    Column({ space: 4 }) {
      Text('¥' + skuInfo.price)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
      Text('x' + skuInfo.count)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .width(48)
    .alignItems(HorizontalAlign.End)
  }
  .alignItems(VerticalAlign.Top)
  .width($r('app.string.size_percent_full'))
}

/**
 * 订单操作按钮列表
 * @param orderInfo
 * @param buttonSize
 */
@Builder
export function buildButtonList(orderInfo: OrderInfo, buttonSize: ControlSize = ControlSize.NORMAL,
  callback?: (action: OrderActionMap) => void) {
  Row({ space: buttonSize === ControlSize.NORMAL ? 12 : 8 }) {
    ForEach(OrderUtil.getButtonList(orderInfo.status), (action: OrderAction) => {
      if (buttonSize === ControlSize.SMALL || (buttonSize === ControlSize.NORMAL && !action.enableHide)) {
        if (!(orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP &&
          action.actionType === OrderActionMap.UPDATE_ADDRESS)) {
          Button(action.label)
            .attributeModifier(new MyButtonModifier(action.style, buttonSize))
            .onClick(() => {
              callback?.(action.actionType)
            })
        }
      }
    }, (action: OrderAction, index: number) => index + action.label)
  }
  .width($r('app.string.size_percent_full'))
  .justifyContent(FlexAlign.End)
}

/**
 * 订单列表页卡片
 * @param order
 */
@Builder
export function buildOrderInfoCard(order: OrderItem) {
  Row() {
    Text(formatFullDate(new Date(order.orderInfo.orderTime)))
      .fontColor($r('app.color.font_color_level3'))
      .fontSize($r('app.float.font_size_12'))
    Text(OrderUtil.getStatusLabel(order.orderInfo.status))
      .fontColor($r('app.color.theme_color'))
      .fontSize($r('app.float.font_size_14'))
  }
  .width($r('app.string.size_percent_full'))
  .justifyContent(FlexAlign.SpaceBetween)
  .margin({ bottom: $r('app.float.space_l') })

  Column({ space: 12 }) {
    ForEach(order.skuInfo, (skuInfo: OrderSkuItem) => {
      Column() {
        buildOrderBaseInfoCard(skuInfo)
      }
      .onClick(() => {
        routerStack.pushPath({ name: RouterMap.ORDER_INFO, param: order.orderInfo.orderNo })
      })
    }, (item: OrderSkuItem, index: number) => index + '__' + item.skuCode)
    Text() {
      Span('总价')
      Span(' ').letterSpacing(2)
      Span('¥' + order.orderInfo.originalPrice)
      Span(' ').letterSpacing(8)
      Span('实付')
      Span(' ').letterSpacing(2)
      Span('¥' + order.orderInfo.finalPrice)
        .fontSize($r('app.float.font_size_16'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
    }
    .width($r('app.string.size_percent_full'))
    .textAlign(TextAlign.End)
    .fontSize($r('app.float.font_size_12'))
    .fontColor($r('app.color.font_color_level3'))
  }
  .margin({ bottom: $r('app.float.space_l') })

  if ((order.orderInfo.status === OrderStatusMap.PENDING_SHIPMENT ||
    order.orderInfo.status === OrderStatusMap.PENDING_RECEIPT) &&
    order.logisticInfo.length > 0) {
    Row({ space: 8 }) {
      Image(order.logisticInfo[0].icon)
        .width(16)
        .height(16)
        .fillColor($r('app.color.font_color_level1'))
      Text(OrderUtil.getLogisticStatusLabel(order.logisticInfo[0].status))
        .fontSize($r('app.float.font_size_12'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'))
      Divider().vertical(true).height(12)
      Text(order.logisticInfo[0].details.length > 0 ?
        (order.logisticInfo[0].details[0].desc ?? '') : '')
        .fontSize($r('app.float.font_size_12'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level2'))
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (order.orderInfo.status === OrderStatusMap.PENDING_RECEIPT){
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
      }
    }
    .width($r('app.string.size_percent_full'))
    .padding($r('app.float.space_m'))
    .backgroundColor($r('app.color.background_color_grey'))
    .borderRadius($r('app.float.border_radius_m'))
    .margin({ bottom: $r('app.float.space_l') })
    .onClick(() => {
      if (order.orderInfo.status === OrderStatusMap.PENDING_RECEIPT) {
        routerStack.pushPath({ name: RouterMap.ORDER_EXPRESS_INFO, param: order });
      }
    })
  }
}


