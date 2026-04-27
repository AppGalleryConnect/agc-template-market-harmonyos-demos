import { OrderStatus, OrderType } from 'common_travel_guide'
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM'

// 退款时间
@ComponentV2
export struct TicketRefundPage {
  @Require @Param ticketVm: TicketPendingPaymentVM

  build() {
    if (this.ticketVm.orderInfo.status === OrderStatus.REFUNDED) {
      Row() {
        Text('退款时间：')
          .fontSize(12)
          .opacity(0.5)
        Text(this.ticketVm.getDate())
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      Row() {
        Text('退票账户：')
          .fontSize(12)
          .opacity(0.5)
        Text('中国银行（8888）')
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      Row() {
        Text('退票金额：')
          .fontSize(12)
          .opacity(0.5)
        if (this.ticketVm.orderInfo.type === OrderType.BUS) {
          Text('¥' + this.ticketVm.dataBusInfo?.returnPrice)
            .fontSize(12)
        }
        if (this.ticketVm.orderInfo.type === OrderType.AIRPLANE) {
          Text('¥' + this.ticketVm.dataInfo.ticketGo?.returnPrice)
            .fontSize(12)
        }
        if (this.ticketVm.orderInfo.type === OrderType.TRAIN) {
          Text('¥' + this.ticketVm.dataPlaneInfo.planeGo?.returnPrice)
            .fontSize(12)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })
    }
  }
}