import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { RouterMap, TValueType } from 'common';
import {
  baseToast,
  OrderInfo,
  OrderStatus,
  PlanePageVM,
  TicketDetailListModel,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey,
  TravelerModel,
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

phoneRouterControl.registerPageBuilder(RouterMap.TICKET_PENDING_PAYMENT_PAGE,
  wrapBuilder(TicketPendingPaymentPageBuilder))

@Builder
export function TicketPendingPaymentPageBuilder(param: TValueType) {
  TicketPendingPaymentPage({
    pageParam: param
  })
}

@ComponentV2
export struct TicketPendingPaymentPage {
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  @Param pageParam: TValueType = null
  ticketVm: TicketPendingPaymentVM = new TicketPendingPaymentVM()
  controller: TextInputController = new TextInputController();
  vmAdd: TravelerModel = new TravelerModel()
  scroller: Scroller = new Scroller()
  vm: PlanePageVM = new PlanePageVM()
  @Local orderInfo: string = 'orderInfo'
  @Local interval: number = 0;
  @Local laterPayTime: Date = new Date()
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
        this.ticketVm.dataInfo.ticketGo.status = OrderStatus.PENDING
        this.ticketVm.orderInfo.status = OrderStatus.PENDING
      }
    });

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  private showRealNameAuthDialog() {
    baseToast.show({
      type: 'dialog',
      hasTitle: '订单确定退订吗？',
      message: '退订后订单不在保留，需重新预定',
      confirmColor: $r('sys.color.font_primary'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmAction: () => {
        this.ticketVm.dataInfo.ticketGo.status = OrderStatus.REFUNDED
        this.ticketVm.dataInfo.ticketGo.scenicRefundCreateDate = this.ticketVm.getDate()
        this.ticketVm.orderInfo.applyRefund()
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
    this.ticketVm.orderInfo = routerParam.orderInfo as OrderInfo
    // 初始化数据
    this.ticketVm.initData()

    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          this.ticketVm.payFinishedUpdate()
          this.cashierPicker.close();
        }
      }
    );

    // 如果是从我的订单页面，点击去付款跳转过来的，需要立即拉起支付弹框
    if (this.isPulUpPay) {
      let payPrice: number = Number(this.ticketVm.orderInfo.detailInfo.ticketGo?.returnPrice)
      // 拉起支付弹框
      this.cashierPicker
        .reset()// 内部状态重置
        .setAmount(payPrice * 100)// 支付金额，单位：分
        .setTradeSummary('')// 订单摘要 (可选，不填则不显示)
        .open();
    }
  }

  getTripTime() {
    // 定义开始时间和结束时间
    let startTime =
      `2025-${this.ticketVm.dataInfo.ticketGo.timeDate}T${this.ticketVm.dataInfo.ticketGo.startDate}:00`; // 格式为 ISO 8601
    let endTime =
      `2025-${this.ticketVm.dataInfo.ticketGo.timeDate}T${this.ticketVm.dataInfo.ticketGo.endDate}:00`; // 注意，这里是21:00，因为9点是晚上9点
    // 转换为Date对象

    let start = new Date(startTime);
    let end = new Date(endTime);
    // 计算时间差（毫秒）
    let timeDiff = end.getTime() - start.getTime();
    // 将毫秒转换为小时（考虑到一天的毫秒数是24*60*60*1000）
    let hoursDiff = timeDiff / (1000 * 60 * 60) as number
    let data = hoursDiff.toString().split('.');
    let timeData = data[0] + '小时' + Number(data[1]) * 0.6 + '分'
    return timeData
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
          // 顶部标题和返回按钮
          this.headTitleBackBuilder()
          // 根据不同装填展示不同的描述
          OrderStatusDescriptionBuilder({ ticketVm: this.ticketVm })
          // 订单详情信息
          Scroll(this.scroller) {
            Column() {
              // 订单详情信息
              this.orderDetailInfoBuilder()
              // 出行人信息
              this.travelPeopleBuilder()
            }
          }
          .padding({ bottom: 100 })
          .layoutWeight(1)
          .borderRadius(16)
          .align(Alignment.TopStart)
          .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
          .scrollBar(BarState.Off) // 滚动条常驻显示
        }
        .layoutWeight(1)
        .padding(16)
        .alignItems(HorizontalAlign.Start)

        // 订单详情底部按钮
        TicketStatusButtonPage({
          planeVm: this.ticketVm, openDialog: (msg: boolean) => {
            if (msg === true) {
              this.showRealNameAuthDialog()
            }
          },
          openCashierPicker: (msg: boolean) => {
            if (msg === true) {
              // 拉起支付弹框
              this.cashierPicker
                .reset()// 内部状态重置
                .setAmount(Number(this.ticketVm.orderInfo.detailInfo.ticketGo?.returnPrice) * 100)// 支付金额，单位：分
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

  // 顶部标题和返回按钮
  @Builder
  headTitleBackBuilder() {
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
  }

  // 订单详情信息
  @Builder
  orderDetailInfoBuilder() {
    Column() {
      Row() {
        Text('总计')
          .fontSize(18)
        Text('¥' + this.ticketVm.dataInfo.ticketGo?.returnPrice)
          .fontColor('#FF4A26')
          .fontSize(18)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      Row() {
        Text('订单号：')
          .fontSize(12)
          .opacity(0.5)
        Text(this.ticketVm.orderInfo.detailInfo?.ticketGo?.ticketOrderNum)
          .fontSize(12)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 16, bottom: 10 })
      .width('100%')

      Row() {
        Text('下单时间：')
          .fontSize(12)
          .opacity(0.5)
        Text(this.ticketVm.getDate())
          .fontSize(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      //已完成/已出票/已退票支付方式
      this.paymentMethodBuilder()
      // 已退票退款方式
      this.refundMethodBuilder()
      if (this.ticketVm.dataInfo.ticketGo?.type === 0) {
        this.goContent('去程', this.ticketVm.dataInfo.ticketGo)
      } else {
        this.goContent('去程', this.ticketVm.dataInfo.ticketGo)
        Blank()
          .width('100%')
          .height(1)
          .borderStyle(BorderStyle.Dashed)
          .borderWidth(1)// 设置边框宽度
          .borderColor('#D8D8D8') // 设置边框颜色
          .margin({ top: 20 })
        //机票返程信息
        this.backContent('返程', this.ticketVm.dataInfo.ticketBack)
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
  }

  //已完成/已出票/已退票支付方式
  @Builder
  paymentMethodBuilder() {
    TicketInformationPage({ planeVm: this.ticketVm })
  }

  // 退款方式
  @Builder
  refundMethodBuilder() {
    TicketRefundPage({ ticketVm: this.ticketVm })
  }

  // 出行人信息
  @Builder
  travelPeopleBuilder() {
    TravelInformationPage({ peopleList: this.ticketVm.dataInfo.ticketGo?.peopleList })
  }

  @Builder
  contentTopBuilder(title: string, ticketDetail: TicketDetailListModel) {
    Row() {
      Row() {
        Text(title)
          .fontSize(10)
          .padding(4)
          .borderRadius(4)
          .backgroundColor('#FEE231')
          .margin({ right: 6 })
          .visibility(ticketDetail?.type === 0 ? Visibility.None : Visibility.Visible)
        Row() {
          Text(title === '去程' ? ticketDetail?.currentCity : ticketDetail?.returnCity)
            .fontSize(14)
          Image($r('app.media.ic_right'))
            .width(20)
          Text(title === '去程' ? ticketDetail?.returnCity : ticketDetail?.currentCity)
            .fontSize(14)
        }
      }
      .layoutWeight(1)
      .margin({ top: 8, bottom: 12 })

      Image(this.ticketVm.goIconBoolen === true ? $r('app.media.ic_ticket_close') : $r('app.media.ic_ticket_open'))
        .width(24)
        .height(24)
        .visibility(title === '去程' ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.ticketVm.goIconBoolen = !this.ticketVm.goIconBoolen
          if (this.ticketVm.goIconBoolen === true) {
            this.ticketVm.goHeight = 60
          } else {
            this.ticketVm.goHeight = 170
          }
        })
      Image(this.ticketVm.backIconBoolen === true ? $r('app.media.ic_ticket_close') : $r('app.media.ic_ticket_open'))
        .width(24)
        .height(24)
        .visibility(title === '返程' ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.ticketVm.backIconBoolen = !this.ticketVm.backIconBoolen
          if (this.ticketVm.backIconBoolen === true) {
            this.ticketVm.backHeight = 60
          } else {
            this.ticketVm.backHeight = 170
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  contentBottomBuilder(ticketDetail: TicketDetailListModel) {
    Row() {
      Image($r('app.media.ic_car_line'))
        .width(4)
        .height(82)
        .margin({ right: 9 })
      Column() {
        Row() {
          Text(ticketDetail?.startDate)
            .fontSize(14)
            .fontColor('#000')
            .margin({ right: 10 })
          Text(ticketDetail?.startLocation)
            .fontSize(14)
            .fontColor('#000')
        }
        .margin({ bottom: 10 })

        Row() {
          Text() {
            Span('飞行时长 ')
            Span(this.ticketVm.getTripTime())
          }
          .fontSize(10)
          .fontColor('#000')
          .opacity(0.4)
        }
        .margin({ bottom: 4 })

        Row() {
          Text(`国航｜${ticketDetail?.aviation}｜${ticketDetail?.boeing}｜有餐食`)
            .fontSize(10)
            .fontColor('#000')
            .opacity(0.4)
        }

        Row() {
          Text(ticketDetail?.endDate)
            .fontSize(14)
            .fontColor('#000')
            .margin({ right: 10 })
          Text(ticketDetail?.endLocation)
            .fontSize(14)
            .fontColor('#000')
        }
        .margin({ top: 20 })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(VerticalAlign.Top)
    .height(82)
    .margin({ top: 12 })
  }

  // 车票信息
  @Builder
  content(title: string, ticketDetail: TicketDetailListModel) {
    Column() {
      this.contentTopBuilder(title, ticketDetail)
      Row() {
        Text(ticketDetail?.timeDate.split('-').join('月') + '日')
          .fontSize(12)
          .margin({ right: 10 })
          .opacity(0.5)
        Text(ticketDetail?.weekDate)
          .fontSize(12)
          .opacity(0.5)
      }

      this.contentBottomBuilder(ticketDetail)

    }
    .alignItems(HorizontalAlign.Start)
  }

  // 去程车票信息
  @Builder
  goContent(title: string, ticketGo: TicketDetailListModel) {
    Column() {
      this.content(title, ticketGo)
    }
    .height(this.ticketVm.goHeight)
    .width('100%')
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  // 返程车票信息
  @Builder
  backContent(title: string, ticketBack: TicketDetailListModel) {
    Column() {
      this.content(title, ticketBack)
    }
    .height(this.ticketVm.backHeight)
    .width('100%')
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 20 })
  }
}

