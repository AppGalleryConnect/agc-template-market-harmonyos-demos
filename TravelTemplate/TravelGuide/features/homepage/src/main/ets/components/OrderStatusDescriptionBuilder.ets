import { OrderStatus } from 'common_travel_guide'
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM'

// 订单状态
@ComponentV2
export struct OrderStatusDescriptionBuilder {
  @Require @Param ticketVm: TicketPendingPaymentVM

  build() {
    Column() {
      if (this.ticketVm.orderInfo?.status === OrderStatus.PENDING) {
        Row() {
          Row() {
            Image($r('app.media.ic_time'))
              .width(20)
              .height(20)
              .margin({ right: 6 })
            Text('待付款')
          }

          Text(this.ticketVm.countDownTime)
            .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('请在' + this.ticketVm.getLaterPayTime() + '前完成支付')
            .fontColor('#FF4A26')
            .fontSize(14)
        }
        .justifyContent(FlexAlign.Start)
        .margin({ top: 9, bottom: 20 })
      }
      if (this.ticketVm.orderInfo?.status === OrderStatus.CANCEL) {
        Row() {
          Text('已取消')
            .fontSize(20)
        }
        .justifyContent(FlexAlign.Start)

        Row() {
          Text('您的订单已取消，请重新预订')
            .fontSize(14)
        }
        .margin({ top: 9, bottom: 20 })
        .justifyContent(FlexAlign.Start)
      }
      if (this.ticketVm.orderInfo?.status === OrderStatus.REFUNDED) {
        Row() {
          Text('已退票')
            .fontSize(20)
        }
        .justifyContent(FlexAlign.Start)

        Row() {
          Text('退款金额已到账')
            .fontSize(14)
        }
        .margin({ top: 9, bottom: 20 })
        .justifyContent(FlexAlign.Start)
      }
      if (this.ticketVm.orderInfo?.status === OrderStatus.ISSUED) {
        Row() {
          Text('已出票')
            .fontSize(20)
        }
        .justifyContent(FlexAlign.Start)

        Row() {
          Text('您的订单已出票，请注意查收')
            .fontSize(14)
        }
        .margin({ top: 9, bottom: 20 })
        .justifyContent(FlexAlign.Start)
      }
      if (this.ticketVm.orderInfo?.status === OrderStatus.FINISHED) {
        Row() {
          Text('已完成')
            .fontSize(20)
        }
        .justifyContent(FlexAlign.Start)

        Row() {
          Text('您的订单已完成')
            .fontSize(14)
        }
        .margin({ top: 9, bottom: 20 })
        .justifyContent(FlexAlign.Start)
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}