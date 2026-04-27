import { TValueType } from 'common';
import {
  baseToast,
  OrderInfo,
  OrderStatus,
  OrderType,
  OrderUtil,
  PlaneDetailListModel,
  PlanePageVM,
  PlaneReturnDetailListModel,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey,
  TravelerModel
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import deviceInfo from '@ohos.deviceInfo';
import { AppStorageV2 } from '@kit.ArkUI';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { TravelInformationPage } from '../components/TravelInformationPage';
import { TicketInformationPage } from '../components/TicketInformationPage';
import { TicketRefundPage } from '../components/TicketRefundPage';
import { OrderStatusDescriptionBuilder } from '../components/OrderStatusDescriptionBuilder';
import { TicketStatusButtonPage } from '../components/TicketStatusButtonPage';

@Builder
export function PlanePendingPaymentPageBuilder(param: TValueType) {
  PlanePendingPaymentPage({
    pageParam: param
  })
}

@ComponentV2
export struct PlanePendingPaymentPage {
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  @Param pageParam: TValueType = null
  planeVm: TicketPendingPaymentVM = new TicketPendingPaymentVM()
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
        this.planeVm.dataPlaneInfo.planeGo.status = OrderStatus.PENDING
        this.planeVm.orderInfo.status = OrderStatus.PENDING
      }
    });

  getStatusText(status: OrderStatus): string {
    this.planeVm.orderInfo.statusText = OrderUtil.getOrderStatusText(status)
    return OrderUtil.getOrderStatusText(status);
  }

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
        this.planeVm.dataPlaneInfo.planeGo.status = OrderStatus.REFUNDED
        this.planeVm.dataPlaneInfo.planeGo.scenicRefundCreateDate = this.planeVm.getDate()
        this.planeVm.orderInfo.applyRefund()
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
    this.planeVm.orderInfo = routerParam.orderInfo as OrderInfo
    this.planeVm.dataPlaneInfo = {
      planeGo: this.planeVm.orderInfo?.detailInfo?.planeGo as PlaneDetailListModel,
      planeBack: this.planeVm.orderInfo?.detailInfo?.planeBack as PlaneDetailListModel
    } as PlaneReturnDetailListModel
    if (this.planeVm.orderInfo.getIsFinish()) {
      this.planeVm.dataPlaneInfo.planeGo.status = OrderStatus.FINISHED
      this.planeVm.orderInfo.ticketFinish()
    }
    this.planeVm.goPrice = Number(this.planeVm.dataPlaneInfo.planeGo.price)
    this.planeVm.backPrice = Number(this.planeVm.dataPlaneInfo.planeBack.price)
    this.planeVm.getTime(this.planeVm.countdownMinutes)
    if (this.planeVm.dataPlaneInfo.planeGo.type === 1) {
      this.planeVm.totalPrice =
        Number(this.planeVm.dataPlaneInfo.planeGo.price) + Number(this.planeVm.dataPlaneInfo.planeBack.price)
    } else {
      this.planeVm.totalPrice = Number(this.planeVm.dataPlaneInfo.planeGo.price)
    }
    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          this.cashierPicker.close();
          this.planeVm.dataPlaneInfo.planeGo.status = OrderStatus.ISSUED
          this.planeVm.orderInfo.status = OrderStatus.ISSUED
          this.planeVm.orderInfo.upTicketDetail()
          this.planeVm.orderInfo.ticketPayedData(OrderType.TRAIN)
        }
      }
    );
    // 如果是从我的订单页面，点击去付款跳转过来的，需要立即拉起支付弹框
    if (this.isPulUpPay) {

      // 拉起支付弹框
      this.cashierPicker
        .reset()// 内部状态重置
        .setAmount(Number(this.planeVm.orderInfo.detailInfo.planeGo?.returnPrice) * 100)// 支付金额，单位：分
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
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.leftReturn'))
                .width(40)
                .height(40)
                .onClick(() => {
                  this.backClick();
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

          OrderStatusDescriptionBuilder({ ticketVm: this.planeVm })
          // 车票详情
          this.ticketDetailBuilder()
        }
        .layoutWeight(1)
        .padding(16)
        .alignItems(HorizontalAlign.Start)

        // 订单详情底部按钮
        TicketStatusButtonPage({
          planeVm: this.planeVm, openDialog: (msg: boolean) => {
            if (msg === true) {
              this.showRealNameAuthDialog()
            }
          },
          openCashierPicker: (msg: boolean) => {
            if (msg === true) {
              // 拉起支付弹框
              this.cashierPicker
                .reset()// 内部状态重置
                .setAmount(Number(this.planeVm.orderInfo.detailInfo.planeGo?.returnPrice) * 100)// 支付金额，单位：分
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
  }

  //车票详情
  @Builder
  ticketDetailBuilder() {
    Scroll(this.scroller) {
      Column() {
        Column() {
          Row() {
            Text('总计')
              .fontSize(18)
            Text('¥' + this.planeVm.dataPlaneInfo.planeGo.returnPrice)
              .fontColor('#FF4A26')
              .fontSize(18)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')

          Row() {
            Text('订单号：')
              .fontSize(12)
              .opacity(0.5)
            Text(this.planeVm.orderInfo.detailInfo?.planeGo?.ticketOrderNum)
              .fontSize(12)
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 16, bottom: 10 })
          .width('100%')

          Row() {
            Text('下单时间：')
              .fontSize(12)
              .opacity(0.5)
            Text(this.planeVm.getDate())
              .fontSize(12)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 10 })

          // 付款方式
          TicketInformationPage({ planeVm: this.planeVm })
          this.refundTimeBuilder()

          if (this.planeVm.dataPlaneInfo.planeGo.type === 0) {
            this.goContent('去程', this.planeVm.dataPlaneInfo.planeGo)
          } else {
            this.goContent('去程', this.planeVm.dataPlaneInfo.planeGo)
            Blank()
              .width('100%')
              .height(1)
              .borderStyle(BorderStyle.Dashed)
              .borderWidth(1) // 设置边框宽度
              .borderColor('#D8D8D8') // 设置边框颜色
              .margin({ top: 20 })
            this.backContent('返程', this.planeVm.dataPlaneInfo.planeBack)
          }
        }
        .padding({
          left: 12,
          right: 12,
          top: 16,
          bottom: 16
        })
        .borderRadius(16)
        .backgroundColor($r('sys.color.icon_on_primary'))

        //出行信息
        this.travelInformationBuilder()
      }
    }
    .layoutWeight(1)
    .align(Alignment.TopStart)
    .borderRadius(16)
    .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
    .scrollBar(BarState.Off) // 滚动条常驻显示
    .padding({ bottom: 100 })
  }

  //退款时间
  @Builder
  refundTimeBuilder() {
    TicketRefundPage({ ticketVm: this.planeVm })
  }

  //出行信息
  @Builder
  travelInformationBuilder() {
    TravelInformationPage({ peopleList: this.planeVm.dataPlaneInfo.planeGo.peopleList })
  }

  @Builder
  content(title: string, planeDetail: PlaneDetailListModel) {
    Column() {
      Row() {
        Row() {
          Text(title)
            .fontSize(10)
            .padding(4)
            .borderRadius(4)
            .backgroundColor('#FEE231')
            .margin({ right: 6 })
            .visibility(planeDetail.type === 0 ? Visibility.None : Visibility.Visible)
          Row() {
            Text(title === '去程' ? planeDetail.currentCity : planeDetail.returnCity)
              .fontSize(14)
            Image($r('app.media.ic_right'))
              .width(20)
            Text(title === '去程' ? planeDetail.returnCity : planeDetail.currentCity)
              .fontSize(14)
          }
        }
        .layoutWeight(1)
        .margin({ top: 8, bottom: 12 })

        Image(this.planeVm.goIconBoolen === true ? $r('app.media.ic_ticket_close') : $r('app.media.ic_ticket_open'))
          .width(24)
          .height(24)
          .visibility(title === '去程' ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.planeVm.goIconBoolen = !this.planeVm.goIconBoolen
            if (this.planeVm.goIconBoolen === true) {
              this.planeVm.goHeight = 60
            } else {
              this.planeVm.goHeight = 170
            }
          })
        // 返程折叠图标
        Image(this.planeVm.backIconBoolen === true ? $r('app.media.ic_ticket_close') : $r('app.media.ic_ticket_open'))
          .width(24)
          .height(24)
          .visibility(title === '返程' ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.planeVm.backIconBoolen = !this.planeVm.backIconBoolen
            if (this.planeVm.backIconBoolen === true) {
              this.planeVm.backHeight = 60
            } else {
              this.planeVm.backHeight = 170
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(planeDetail.timeDate.split('-')
          .join('月') + '日')
          .fontSize(12)
          .margin({ right: 8 })
          .opacity(0.5)
          .margin({ right: 10 })
        Text(planeDetail.weekDate)
          .fontSize(12)
          .opacity(0.5)
      }

      Row() {
        Image($r('app.media.ic_car_line'))
          .width(4)
          .height(82)
          .margin({ right: 9 })
        Column() {
          Row() {
            Text(planeDetail.startDate)
              .margin({ right: 10 })
              .fontSize(14)
            Text(planeDetail.startLocation)
              .fontSize(14)
          }
          .margin({ bottom: 10 })

          Row() {
            Text() {
              Span('行程 ')
              Span(this.planeVm.getTripTime())
            }
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
          }
          .margin({ bottom: 4 })

          Row() {
            Text('15车｜12A｜' + planeDetail.seatClass)
              .fontSize(10)
              .fontColor('#000')
              .opacity(0.4)
          }

          Row() {
            Row() {
              Text(planeDetail.endDate)
                .margin({ right: 10 })
                .fontSize(14)
                .fontColor('#000')
              Text(planeDetail.endLocation)
                .fontSize(14)
                .fontColor('#000')
            }
          }
          .margin({ top: 20 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Top)
      .height(82)
      .margin({ top: 12 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  // 返程车票信息
  @Builder
  backContent(title: string, planeBack: PlaneDetailListModel) {
    Column() {
      this.content(title, planeBack)
    }
    .height(this.planeVm.backHeight)
    .width('100%')
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 20 })
  }

  // 去程车票信息
  @Builder
  goContent(title: string, planeGo: PlaneDetailListModel) {
    Column() {
      this.content(title, planeGo)
    }
    .height(this.planeVm.goHeight)
    .width('100%')
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }
}