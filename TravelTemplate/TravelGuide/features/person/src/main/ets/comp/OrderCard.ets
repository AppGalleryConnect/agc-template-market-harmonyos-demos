import { GlobalContext, RouterMap } from 'common';
import {
  OrderDetailInfo,
  OrderInfo,
  OrderStatus,
  OrderType,
  PassengerInfo,
  TourOrderRouterParam
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';

@ComponentV2
export struct OrderCard {
  @Param @Require data: OrderInfo
  @Event deleteItem: (id: string) => void = () => {
  }
  ctx: UIContext = GlobalContext.getUIContext();

  getStatusFontColor() {
    if (this.data.isShowGray()) {
      return 'rgba(0, 0, 0, 0.30)'
    } else if (this.data.status === OrderStatus.ISSUED) {
      return '#FF890B'
    } else if ([OrderStatus.ISSUED, OrderStatus.BOOKED].includes(this.data.status)) {
      return '#FF890B'
    } else if (this.data.status === OrderStatus.PENDING) {
      return '#FF0B0B'
    }
    return 'rgba(0, 0, 0, 0.70)'
  }

  getFontColor(color: string) {
    return this.data.isShowGray() ? 'rgba(0, 0, 0, 0.30)' : color
  }

  cancelOrder() {
    this.ctx.showAlertDialog({
      title: '您需要取消此订单吗？',
      message: '取消后将不在享受订单优惠活动',
      width: 328,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.50)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.data.cancelOrder()
          }
        }
      ]
    })
  }

  goPayOrder(data: OrderInfo) {
    this.data.goPayOrder(data)
  }

  applyRefund() {
    this.ctx.showAlertDialog({
      title: '您需要申请退款吗？',
      message: '',
      width: 328,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.50)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.data.applyRefund()
          }
        }
      ]
    })
  }

  @Builder
  cardTitleBuilder() {
    Row() {
      Row({ space: 5 }) {
        Image(this.data.icon)
          .width(16)
          .height(16)
        Text(this.data.type)
          .fontSize(14)
          .fontColor(this.getFontColor('#000'))
      }

      Row({ space: 16 }) {
        Text(this.data.statusText)
          .fontSize(12)
          .fontColor(this.getStatusFontColor())
        if ([OrderStatus.FINISHED, OrderStatus.CANCEL, OrderStatus.REFUNDED].includes(this.data.status)) {
          Image($r('app.media.ic_delete'))
            .width(14)
            .height(14)
            .onClick(() => {
              this.deleteItem(this.data.id)
            })
        }
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  cardNameBuilder(data: OrderDetailInfo, label: string) {
    Row({ space: 8 }) {
      if (this.data.returnDetailInfo) {
        Text(label)
          .goOrBackTextStyle()
      }
      if ([OrderType.TRAIN, OrderType.AIRPLANE, OrderType.BUS].includes(this.data.type)) {
        Text(data.departurePlace)
          .fontColor(this.getFontColor('#000'))
          .fontSize(16)
          .fontWeight(500)
        Image($r('app.media.travel_arrow'))
          .width(20)
          .height(20)
        Text(data.destination)
          .fontColor(this.getFontColor('#000'))
          .fontSize(16)
          .fontWeight(500)
      } else {
        Text(this.data.name)
          .fontColor(this.getFontColor('#000'))
          .fontSize(16)
          .fontWeight(500)
      }
    }
  }

  @Builder
  cardDescBuilder(data: OrderDetailInfo) {
    if (this.data.type === OrderType.HOTEL) {
      Text(this.data.detailInfo.hotelLocation)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      Text(`${this.data.detailInfo.startTime}至${this.data.detailInfo.endTime} · ${this.data.detailInfo.roomDesc} · ${this.data.detailInfo.roomName}`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
    }
    if (this.data.type === OrderType.SCENIC) {
      Text(`${this.data.detailInfo.startTime}至${this.data.detailInfo.endTime}`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
    }
    if (this.data.type === OrderType.TRAIN) {
      Text(`${data.startTime}至${data.endTime}`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      ForEach(this.data.passengerInfo, (item: PassengerInfo) => {
        Text(`${item.name} ${item.seatNo?.split(' ')[1]}`)
          .fontSize(13)
          .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      }, (item: PassengerInfo) => JSON.stringify(item))
    }
    if (this.data.type === OrderType.BUS) {
      Text(`${this.data.detailInfo.startTime} 发车`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      ForEach(this.data.passengerInfo, (item: PassengerInfo) => {
        Text(`${item.name}`)
          .fontSize(13)
          .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      }, (item: PassengerInfo) => JSON.stringify(item))
    }
    if (this.data.type === OrderType.AIRPLANE) {
      Text(`${data.startTime}至${data.endTime}`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
      Text(`${data.flightNumber} ${data.boardingGate}出发`)
        .fontSize(13)
        .fontColor(this.getFontColor('rgba(0, 0, 0, 0.50)'))
    }
  }

  @Builder
  cardPriceBuilder() {
    Column({ space: 2 }) {
      Row({ space: 6 }) {
        Text('订单金额')
          .fontColor(this.getFontColor('rgba(0, 0, 0, 0.70)'))
          .fontSize(12)
        Text('¥ ' + this.data.price.toString())
          .fontColor(this.getFontColor('#000'))
          .fontSize(18)
      }

      if (this.data.status === OrderStatus.REFUNDED) {
        Row({ space: 6 }) {
          Text('已退款')
            .fontColor('rgba(0, 0, 0, 0.30)')
            .fontSize(12)
          Text(this.data.price.toString())
            .fontColor('rgba(0, 0, 0, 0.30)')
            .fontSize(12)
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.End)
    .margin({ top: 4 })
  }

  @Builder
  cardBtnBuilder() {
    Row({ space: 8 }) {
      if (this.data.status === OrderStatus.PENDING ||
        (this.data.status === OrderStatus.BOOKED && this.data.type === OrderType.HOTEL)) {
        Text('取消订单')
          .textBtnStyle()
          .onClick(() => {
            this.cancelOrder()
          })
      }
      if ([OrderStatus.PENDING].includes(this.data.status)) {
        Text('去付款')
          .textBtnStyle()
          .onClick(() => {
            this.goPayOrder(this.data)
          })
      }
      if ([OrderStatus.ISSUED].includes(this.data.status) ||
        (this.data.status === OrderStatus.BOOKED && this.data.type === OrderType.SCENIC)) {
        Text('申请退款')
          .textBtnStyle()
          .onClick(() => {
            this.applyRefund()
          })
      }
      if ([OrderStatus.ISSUED, OrderStatus.FINISHED].includes(this.data.status)) {
        Text('报销凭证')
          .textBtnStyle()
          .onClick(() => {
            this.data.reimburseInvoice()
          })
      }
      if ([OrderStatus.FINISHED, OrderStatus.CANCEL, OrderStatus.ISSUED].includes(this.data.status) ||
        (this.data.status === OrderStatus.BOOKED && this.data.type === OrderType.SCENIC)) {
        Text('再次预定')
          .textBtnStyle()
          .onClick(() => {
            this.data.bookAgain()
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  private showToast(msg: string): void {
    this.ctx.getPromptAction().showToast({ message: msg });
  }

  build() {
    Column({ space: 8 }) {
      this.cardTitleBuilder()
      this.cardNameBuilder(this.data.detailInfo, '去程')
      this.cardDescBuilder(this.data.detailInfo)
      if (this.data.returnDetailInfo) {
        this.cardNameBuilder(this.data.returnDetailInfo, '返程')
        this.cardDescBuilder(this.data.returnDetailInfo)
      }
      this.cardPriceBuilder()
      this.cardBtnBuilder()
    }
    .onClick(() => {
      if (this.data.type === OrderType.HOTEL) {
        let param: TourOrderRouterParam = {
          orderInfo: this.data,
          isPulUpPay: false
        }
        phoneRouterControl.jumpPage({
          pageName: RouterMap.HOTEL_ORDER_DETAIL_PAGE,
          param: param
        })
      }
      let param: TourOrderRouterParam = {
        orderInfo: this.data,
        isPulUpPay: false
      }
      if (this.data.type === OrderType.AIRPLANE) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TICKET_PENDING_PAYMENT_PAGE,
          param: param
        })
      }
      if (this.data.type === OrderType.TRAIN) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PLANE_PENDING_PAYMENT_PAGE,
          param: param
        })
      }
      if (this.data.type === OrderType.BUS) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CAR_PENDING_PAYMENT_PAGE,
          param: param
        })
      }
      if (this.data.type === OrderType.SCENIC) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TOUR_ORDER_DETAIL_PAGE,
          param: param
        })
      }
    })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius(16)
    .padding(12)
    .backgroundColor('#fff')
  }
}

@Extend(Text)
function textBtnStyle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.70)')
  .padding({
    top: 8,
    bottom: 8
  })
  .width(76)
  .textAlign(TextAlign.Center)
  .backgroundColor('#fff')
  .borderRadius(24)
  .border({ width: 1, color: 'rgba(0, 0, 0, 0.10)' })
}

@Extend(Text)
function goOrBackTextStyle() {
  .fontSize(10)
  .fontColor('#000')
  .padding({
    top: 2,
    left: 4,
    right: 4,
    bottom: 2
  })
  .backgroundColor('#FEE231')
  .borderRadius(4)
}
