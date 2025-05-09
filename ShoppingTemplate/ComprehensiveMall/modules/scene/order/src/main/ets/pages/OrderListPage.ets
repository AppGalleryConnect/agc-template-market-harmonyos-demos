import { OrderCardVM, OrderSkuDto } from '@common/customtypes';
import { iResourceMgr } from '@common/resource';
import { OrderListPageLogic } from '../logic/OrderListPageLogic';
import { client } from '@common/network';
import { CallButton } from '@components/callbutton';

@ComponentV2
struct OrderListPage {

  @Param
  public logic: OrderListPageLogic = new OrderListPageLogic();

  @Param
  public type: number = 0;

  build(): void {
    if (this.logic.isLoading) {
      Column() {
        LoadingProgress()
          .width(37)
          .height(37)
          .offset({ y: -50 })
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.Center)
    } else {
      Stack() {
        Scroll() {
          if (this.logic.orderCards.length === 0) {
            Column() {
              Column() {
                Image($r('app.media.empty_status_logo'))
                  .width(160)
                  .height(160)
                  .draggable(false)
                  .objectFit(ImageFit.Cover)
                  .margin({ bottom: 15 })
                Text('您还没有相关订单')
                  .fontSize(13)
                  .fontColor($r('sys.color.mask_secondary'))
                  .margin({ bottom: 15 })
              }
              .width('100%')
              .height('45%')
              .borderRadius(12)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Color.White)
            }
            .height('100%')
            .justifyContent(FlexAlign.Start)
            .padding(13)
          } else {
            Column() {
              ForEach(this.logic.orderCards, (card: OrderCardVM) => {
                buildOrderCard(this.logic, card)
              })
            }
            .width('100%')
            .constraintSize({ minHeight: '100%' })
            .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
            .padding({ left: 13, right: 13 })
          }
        }
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
        if (this.logic.showLoading) {
          Column() {
            LoadingProgress()
              .width(37)
              .height(37)
              .offset({ y: -50 })
          }
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
          .justifyContent(FlexAlign.Center)
        }
      }
    }
  }
}

@Builder
export function buildOrderListPage(logic: OrderListPageLogic) {
  OrderListPage({ logic: logic })
}

@Builder
function buildOrderCard(logic: OrderListPageLogic, card: OrderCardVM) {
  Column() {
    Row() {
      Text(card.time)
        .fontSize(12)
        .fontColor($r('sys.color.mask_tertiary'))
      Text(card.statusDesc)
        .fontSize(13)
        .fontColor('#FFE64566')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    Column() {
      ForEach(card.skuList, (sku: OrderSkuDto) => {
        buildSkuCard(logic, sku)
      })
    }
    Row() {
      Text('总价¥' + card.totalPrice)
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(12)
        .margin({ right: 8 })
      Text('实付')
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(12)
      Text('¥' + card.totalPrice)
        .fontColor('#E6000000')
        .fontSize(14)
        .fontWeight(600)
    }
    .width('100%')
    .margin({ top: 13 })
    .justifyContent(FlexAlign.End)
    Row() {
      if (card.type === 0) {
        buildDeleteButton(logic, card)
      } else if (card.type === 1) {
        buildCancelButton(logic, card)
        buildPaymentButton(logic, card)
      } else if (card.type === 2) {
        buildRefundButton(logic, card)
      } else if (card.type === 3) {
        buildRefundButton(logic, card)
        buildAgreeButton(logic, card)
      } else if (card.type === 4) {
        buildCallButton()
      }
    }
    .margin({ top: 13 })
  }
  .width('100%')
  .padding(13)
  .borderRadius(13)
  .backgroundColor(Color.White)
  .margin({ top: 13 })
  .alignItems(HorizontalAlign.End)
}

@Builder
function buildDeleteButton(logic: OrderListPageLogic, card: OrderCardVM) {
  Button() {
    Text('删除订单')
      .fontSize(13)
      .fontColor($r('sys.color.mask_secondary'))
  }
  .width(80)
  .height(30)
  .type(ButtonType.Normal)
  .backgroundColor(Color.White)
  .borderWidth(1)
  .borderColor($r('sys.color.mask_secondary'))
  .borderRadius(18)
  .margin({ left: 8 })
  .onClick(() => {
    logic.showLoading = true;
    client.order.deleteOrderByCode(card.orderCode)
      .then(() => logic.refresh(false))
  })
}

@Builder
function buildCancelButton(logic: OrderListPageLogic, card: OrderCardVM) {
  Button() {
    Text('取消订单')
      .fontSize(13)
      .fontColor($r('sys.color.mask_secondary'))
  }
  .width(80)
  .height(30)
  .type(ButtonType.Normal)
  .backgroundColor(Color.White)
  .borderWidth(1)
  .borderColor($r('sys.color.mask_secondary'))
  .borderRadius(18)
  .margin({ left: 8 })
}

@Builder
function buildPaymentButton(logic: OrderListPageLogic, card: OrderCardVM) {
  Button() {
    Text('去支付')
      .fontSize(13)
      .fontColor(Color.White)
  }
  .width(80)
  .height(30)
  .type(ButtonType.Normal)
  .backgroundColor('#FFE64566')
  .borderRadius(18)
  .margin({ left: 8 })
}

@Builder
function buildRefundButton(logic: OrderListPageLogic, card: OrderCardVM) {
  Button() {
    Text('退款')
      .fontSize(13)
      .fontColor($r('sys.color.mask_secondary'))
  }
  .width(80)
  .height(30)
  .type(ButtonType.Normal)
  .backgroundColor(Color.White)
  .borderWidth(1)
  .borderColor($r('sys.color.mask_secondary'))
  .borderRadius(18)
  .margin({ left: 8 })
  .onClick(() => {
    logic.showLoading = true;
    client.order.refundOrderByCode(card.orderCode)
      .then(() => logic.refresh(false))
  })
}

@Builder
function buildAgreeButton(logic: OrderListPageLogic, card: OrderCardVM) {
  Button() {
    Text('确认收货')
      .fontSize(13)
      .fontColor(Color.White)
  }
  .width(80)
  .height(30)
  .type(ButtonType.Normal)
  .backgroundColor('#FFE64566')
  .borderRadius(18)
  .margin({ left: 8 })
  .onClick(() => {
    logic.showLoading = true;
    client.order.agreeOrderByCode(card.orderCode)
      .then(() => logic.refresh(false))
  })
}

@Builder
function buildCallButton() {
  CallButton() {
    Button() {
      Text('联系商家')
        .fontSize(13)
        .fontColor(Color.White)
    }
    .width(80)
    .height(30)
    .type(ButtonType.Normal)
    .backgroundColor('#FFE64566')
    .borderRadius(18)
    .margin({ left: 8 })
  }
}

@Builder
function buildSkuCard(logic: OrderListPageLogic, sku: OrderSkuDto) {
  Row() {
    Image(iResourceMgr.resolveUri(sku.banner))
      .width(65)
      .height(65)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .borderRadius(7)
      .margin({ right: 10 })
      .backgroundColor('#90E5E7E9')
    Column() {
      Row() {
        Text(sku.title)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(14)
          .fontColor($r('sys.color.mask_secondary'))
        Text() {
          Span('¥')
            .fontSize(13)
          Span(sku.price.toString())
            .fontSize(13)
        }
        .fontColor($r('sys.color.mask_secondary'))
        .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text(sku.skuDesc)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(12)
        Text('x' + sku.count)
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(65)
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .width('100%')
  .margin({ top: 13 })
}
