import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { TValueType } from 'common';
import {
  baseToast,
  OrderInfo,
  OrderStatus,
  OrderType,
  PlaneDetailListModel,
  PlanePageVM,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey,
  TravelerModel
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import deviceInfo from '@ohos.deviceInfo';
import { AppStorageV2 } from '@kit.ArkUI';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { TravelInformationPage } from '../components/TravelInformationPage';
import { TicketInformationPage } from '../components/TicketInformationPage';
import { TicketRefundPage } from '../components/TicketRefundPage';
import { TicketStatusButtonPage } from '../components/TicketStatusButtonPage';
import { OrderStatusDescriptionBuilder } from '../components/OrderStatusDescriptionBuilder';

@Builder
export function CarPendingPaymentPageBuilder(param: TValueType) {
  CarPendingPaymentPage({
    pageParam: param
  })
}

@ComponentV2
export struct CarPendingPaymentPage {
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  @Param pageParam: TValueType = null
  busVm: TicketPendingPaymentVM = new TicketPendingPaymentVM()
  vm: PlanePageVM = new PlanePageVM()
  controller: TextInputController = new TextInputController();
  vmAdd: TravelerModel = new TravelerModel()
  scroller: Scroller = new Scroller()
  @Local orderInfo: string = 'orderInfo'
  @Local laterPayTime: Date = new Date()
  @Local countDownTime: string = ''
  @Local isPulUpPay: boolean = false
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();
  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // todo: 根据支付类型向服务器请求支付所需参数
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: this.orderInfo }, this.navPathStack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        if (deviceInfo.marketName === 'emulator') {
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: this.orderInfo });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(this.uiContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          });
        if (!isWeChatOpenSuccess) {
          this.showToast('微信拉起失败');
        }
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
        this.busVm.dataBusInfo.status = OrderStatus.PENDING
        this.busVm.orderInfo.status = OrderStatus.PENDING
      }
    });

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  private showRealNameAuthDialog() {
    baseToast.show({
      type: 'dialog',
      hasTitle: '订单确定退订吗？',
      message: '退订后订单不在保留，需重新预定',
      confirmColor: $r('sys.color.font_primary'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmAction: () => {
        this.busVm.dataBusInfo.status = OrderStatus.REFUNDED
        this.busVm.dataBusInfo.scenicRefundCreateDate = this.busVm.getDate()
        this.busVm.orderInfo.applyRefund()
        baseToast.hide();
      },
      cancelAction: () => {
        baseToast.hide();
      },
    });
  }

  aboutToAppear(): void {
    let routerParam = this.pageParam as TourOrderRouterParam
    this.isPulUpPay = routerParam.isPulUpPay
    this.busVm.orderInfo = routerParam.orderInfo as OrderInfo
    this.busVm.dataBusInfo = this.busVm.orderInfo.detailInfo.busGo as PlaneDetailListModel
    if (this.busVm.orderInfo.getIsFinish()) {
      this.busVm.dataBusInfo.status = OrderStatus.FINISHED
      this.busVm.orderInfo.ticketFinish()
    }
    this.busVm.getTime(this.busVm.countdownMinutes)
    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          this.cashierPicker.close();
          this.busVm.dataBusInfo.status = OrderStatus.ISSUED
          this.busVm.orderInfo.status = OrderStatus.ISSUED
          this.busVm.orderInfo.upTicketDetail()
          this.busVm.orderInfo.ticketPayedData(OrderType.TRAIN)
        }
      }
    );
    // 如果是从我的订单页面，点击去付款跳转过来的，需要立即拉起支付弹框
    if (this.isPulUpPay) {
      // 拉起支付弹框
      this.cashierPicker
        .reset()// 内部状态重置
        .setAmount(Number(this.busVm.orderInfo.detailInfo.busGo?.returnPrice) * 100)// 支付金额，单位：分
        .setTradeSummary('')// 订单摘要 (可选，不填则不显示)
        .open();
    }
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.backClick();
      return true
    })
    .backgroundImage($r('app.media.ic_orderDetail_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  backClick() {
    if (phoneRouterControl.getNavPageInfoList().length > 2) {
      phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length - 2)
    } else {
      phoneRouterControl.popPage()
    }
  }

  @Builder
  render() {
    Column() {
      Column() {
        Column() {
          Row() {
            Image($r('app.media.leftReturn'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.backClick();
                return true
              })
            Row() {
              Text('订单详情')
                .fontSize(20)
                .fontColor('#000')
            }
            .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 30 })
        }
        .padding({ top: 44 })

        OrderStatusDescriptionBuilder({ ticketVm: this.busVm })

        Scroll(this.scroller) {
          Column() {
            Column() {
              Row() {
                Text('总计')
                  .fontSize(18)
                Text('¥' + this.busVm.dataBusInfo.returnPrice)
                  .fontColor('#FF4A26')
                  .fontSize(18)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')

              Row() {
                Text('订单号：')
                  .fontSize(12)
                  .opacity(0.5)
                Text(this.busVm.orderInfo.detailInfo?.busGo?.ticketOrderNum)
                  .fontSize(12)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ top: 16, bottom: 10 })
              .width('100%')

              Row() {
                Text('下单时间：')
                  .fontSize(12)
                  .opacity(0.5)
                Text(this.busVm.getDate())
                  .fontSize(12)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })

              // 付款时间
              TicketInformationPage({ planeVm: this.busVm })
              // 退款时间
              TicketRefundPage({ ticketVm: this.busVm })
              // 汽车票详细信息
              this.content()
            }
            .padding({
              left: 12,
              right: 12,
              top: 16,
              bottom: 16
            })
            .borderRadius(16)
            .backgroundColor($r('sys.color.icon_on_primary'))

            TravelInformationPage({ peopleList: this.busVm.dataBusInfo.peopleList })
          }
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .borderRadius(16)
        .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
        .scrollBar(BarState.Off) // 滚动条常驻显示
      }
      .layoutWeight(1)
      .padding(16)
      .alignItems(HorizontalAlign.Start)

      // 订单详情底部按钮
      TicketStatusButtonPage({
        planeVm: this.busVm, openDialog: (msg: boolean) => {
          if (msg === true) {
            this.showRealNameAuthDialog()
          }
        },
        openCashierPicker: (msg: boolean) => {
          if (msg === true) {
            // 拉起支付弹框
            this.cashierPicker
              .reset()// 内部状态重置
              .setAmount(Number(this.busVm.orderInfo.detailInfo.busGo?.returnPrice) * 100)// 支付金额，单位：分
              .setTradeSummary('')// 订单摘要 (可选，不填则不显示)
              .open();
          }
        }
      })
        .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  content() {
    Column() {
      Row() {
        Row() {
          Row() {
            Text(this.busVm.dataBusInfo.currentCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(this.busVm.dataBusInfo.returnCity)
              .fontSize(14)
          }
          .margin({ top: 8, bottom: 12 })
        }
        .layoutWeight(1)

        Image(this.busVm.goIconBoolen === true ? $r('app.media.ic_ticket_close') : $r('app.media.ic_ticket_open'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.busVm.goIconBoolen = !this.busVm.goIconBoolen
            if (this.busVm.goIconBoolen === true) {
              this.busVm.goHeight = 60
            } else {
              this.busVm.goHeight = 170
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(this.busVm.dataBusInfo.timeDate)
          .fontSize(14)
          .margin({ right: 10 })
        Text(this.busVm.dataBusInfo.weekDate)
          .fontSize(14)
      }

      Row() {
        Image($r('app.media.ic_car_line'))
          .width(4)
          .height(82)
          .margin({ right: 9 })
        Column() {
          Row() {
            Text(this.busVm.dataBusInfo.startDate)
              .margin({ right: 10 })
              .fontSize(14)
              .fontColor('#000')
            Text(this.busVm.dataBusInfo.startLocation)
              .fontSize(14)
              .fontColor('#000')
          }
          .margin({ bottom: 10 })

          Row() {
            Text('发车')
              .margin({ right: 10 })
              .fontSize(10)
              .fontColor('#000')
              .opacity(0.4)
            Text(this.busVm.dataBusInfo.startDate)
              .fontSize(10)
              .fontColor('#000')
              .opacity(0.4)
          }
          .margin({ bottom: 4 })

          Row() {
            Text() {
              Span('行程')
              Span('约' + this.busVm.dataBusInfo.duration)
            }
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          }
          .margin({ bottom: 4 })

          Row() {
            Text(this.busVm.dataBusInfo.seatClass)
              .fontSize(10)
              .fontColor('#000')
              .opacity(0.4)
          }

          Row() {
            Text(this.busVm.dataBusInfo.endDate)
              .fontSize(14)
              .fontColor('#000')
              .margin({ right: 10 })
            Text(this.busVm.dataBusInfo.endLocation)
              .fontSize(14)
              .fontColor('#000')
          }
          .margin({ top: 16 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Top)
      .height(82)
      .margin({ top: 12 })
    }
    .height(this.busVm.goHeight)
    .clip(true)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 14 })
  }
}