import { BarVM, RouterMap } from 'common'
import { HotelDateModel, HotelModel, OrderStatus, OrderType, PlanePageVM } from 'common_travel_guide'
import { phoneRouterControl } from 'oh_router'
import { PlaneTicketPageBuilder, TicketParam } from '../view/PlaneTicketPage'
import { ReimbursementVoucherPageBuilder } from '../view/ReimbursementVoucherPage'
import { TicketPricesPageBuilder } from '../view/TicketPricesPage'
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM'

// 订单详情按钮
@ComponentV2
export struct TicketStatusButtonPage {
  @Require @Param planeVm: TicketPendingPaymentVM
  vm: PlanePageVM = new PlanePageVM()
  @Event openDialog: (msg: boolean) => void = () => {
  }
  @Event openCashierPicker: (msg: boolean) => void = () => {
  }

  build() {
    Column() {
      if (this.planeVm.orderInfo.status === OrderStatus.CANCEL) {
        Row() {
          this.bookAgainBuilder()
        }
        .width('100%')
      }
      if (this.planeVm.orderInfo.status === OrderStatus.PENDING) {
        Row({ space: 16 }) {
          Text('取消订单')
            .fontSize(14)
            .fontColor('#000')
            .borderWidth(1)
            .textAlign(TextAlign.Center)
            .borderColor('#f3f3f3')
            .operationStyle()
            .height(40)
            .onClick(() => {
              this.planeVm.cancelOrder()
            })

          Text('去付款')
            .fontSize(14)
            .operationStyle()
            .textAlign(TextAlign.Center)
            .backgroundColor('#FFE431')
            .height(40)
            .onClick(() => {
              this.openCashierPicker(true)
            })
        }
        .width('100%')
      }
      if (this.planeVm.orderInfo.status === OrderStatus.ISSUED) {
        Row({ space: 16 }) {
          Text('申请退款')
            .fontSize(14)
            .textAlign(TextAlign.Center)
            .operationStyle()
            .borderWidth(1)
            .borderColor('#f3f3f3')
            .height(40)
            .onClick(() => {
              this.openDialog(true)
            })

          // 报销凭证
          this.reimbursementVoucherBuilder()
          // 再次预定
          this.bookAgainBuilder()
        }
        .width('100%')
      }
      if (this.planeVm.orderInfo.status === OrderStatus.FINISHED) {
        Row({ space: 16 }) {
          this.reimbursementVoucherBuilder()
          this.bookAgainBuilder()
        }
        .width('100%')
        .height(64)
      }
    }
    .width('100%')
    .padding({
      left: 16,
      top: 16,
      right: 16,
      bottom: BarVM.instance.aiBarH + 12,
    })
    .backgroundColor($r('sys.color.icon_on_primary'))
  }

  // 报销凭证
  @Builder
  reimbursementVoucherBuilder() {
    Text('报销凭证')
      .fontSize(14)
      .fontColor('#000')
      .borderWidth(1)
      .textAlign(TextAlign.Center)
      .borderColor('#f3f3f3')
      .operationStyle()
      .height(40)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.REIMBURSEMENT_VOUCHER_PAGE,
          builder: wrapBuilder(ReimbursementVoucherPageBuilder),
          param: this.planeVm.orderInfo.price
        })
      })
  }

  // 再次预定
  @Builder
  bookAgainBuilder() {
    Text('再次预定')
      .fontSize(14)
      .height(40)
      .operationStyle()
      .textAlign(TextAlign.Center)
      .backgroundColor('#FFE431')
      .onClick(() => {
        if (this.planeVm.orderInfo.type === OrderType.TRAIN) {
          this.vm.returnSatus = this.planeVm.dataPlaneInfo.planeGo.type
          this.vm.chooseStatus = this.planeVm.dataPlaneInfo.planeGo.chooseStatus
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_TICKET_PAGE,
            builder: wrapBuilder(PlaneTicketPageBuilder),
            param: '火车票'
          })
        }
        if (this.planeVm.orderInfo.type === OrderType.AIRPLANE) {
          this.vm.returnSatus = this.planeVm.dataInfo.ticketGo.type
          this.vm.chooseStatus = this.planeVm.dataInfo.ticketGo.chooseStatus
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_TICKET_PAGE,
            builder: wrapBuilder(PlaneTicketPageBuilder),
            param: '机票'
          })
        }
        if (this.planeVm.orderInfo.type === OrderType.BUS) {
          this.vm.returnSatus = this.planeVm.dataBusInfo.type
          this.vm.chooseStatus = this.planeVm.dataBusInfo.chooseStatus
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PLANE_TICKET_PAGE,
            builder: wrapBuilder(PlaneTicketPageBuilder),
            param: '汽车票'
          })
        }

      })
  }

  @Styles
  operationStyle(){
    .padding({ top: 12, bottom: 12 })
    .borderRadius(24)
    .flexGrow(1)
  }
}