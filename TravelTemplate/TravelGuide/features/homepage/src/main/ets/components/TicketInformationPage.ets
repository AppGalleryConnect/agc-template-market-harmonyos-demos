import { OrderStatus } from 'common_travel_guide'
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM'

// 付款时间
@ComponentV2
export struct TicketInformationPage {
  @Require @Param planeVm: TicketPendingPaymentVM

  build() {
    if (this.planeVm.orderInfo.status === OrderStatus.ISSUED ||
      this.planeVm.orderInfo.status === OrderStatus.FINISHED ||
      this.planeVm.orderInfo.status === OrderStatus.REFUNDED) {
      Row() {
        Text('付款时间：')
          .fontSize(12)
          .opacity(0.5)
        Text(this.planeVm.getDate())
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      Row() {
        Text('支付方式：')
          .fontSize(12)
          .opacity(0.5)
        Text('在线支付')
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })
    }
  }
}