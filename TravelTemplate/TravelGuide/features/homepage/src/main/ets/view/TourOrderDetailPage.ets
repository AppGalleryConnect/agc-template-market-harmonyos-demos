import { phoneRouterControl } from 'oh_router';
import { BarVM, GlobalContext, RouterMap, TValueType } from 'common';
import deviceInfo from '@ohos.deviceInfo';
import {
  OrderStatus,
  OrderUtil,
  PassengerInfo,
  TourModel,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey
} from 'common_travel_guide';
import { TourOrderDetailPageVM } from '../viewmodel/TourOrderDetailPageVM';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

phoneRouterControl.registerPageBuilder(RouterMap.TOUR_ORDER_DETAIL_PAGE, wrapBuilder(TourOrderDetailPageBuilder))

@Builder
export function TourOrderDetailPageBuilder(params?: TValueType) {
  TourOrderDetailPage({ pageParam: params as TourModel })
}

@ComponentV2
export struct TourOrderDetailPage {
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  vm: TourOrderDetailPageVM = new TourOrderDetailPageVM()
  @Param pageParam: TValueType = null
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  @Local orderInfo: string = 'orderInfo'
  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        this.vm.payType = PaymentType.ALIPAY
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: this.orderInfo }, this.navPathStack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        this.vm.payType = PaymentType.HUAWEI
        if (deviceInfo.marketName === 'emulator') {
          this.vm.orderStatus = OrderStatus.PENDING
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        this.vm.payType = PaymentType.WECHAT
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
          this.vm.orderStatus = OrderStatus.PENDING
        }
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
      }
    });

  private CustomDialog(msg: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  aboutToAppear(): void {
    let param = this.pageParam as TourOrderRouterParam
    let orderInfo = param.orderInfo
    this.vm.orderInfo = orderInfo
    this.vm.detailInfo = orderInfo?.detailInfo
    this.vm.passengerInfo = orderInfo?.passengerInfo
    this.vm.orderStatus = orderInfo.status
    // 判断是否是已完成状态，处理完成状态
    if (this.vm.orderInfo.getIsFinish()) {
      this.vm.orderStatus = OrderStatus.FINISHED
      this.vm.orderInfo.scenicFinish()
    }
    this.vm.orderStatusText = OrderUtil.getOrderStatusText(this.vm.orderStatus)
    this.vm.orderDescription = this.vm.getOrderDescription(this.vm.orderStatus)
    this.vm.isPulUpPay = param.isPulUpPay
    // 如果是从我的订单页面，点击去付款跳转过来的，需要立即拉起支付弹框
    if (this.vm.isPulUpPay) {
      this.vm.orderTime = new Date();
      let totalPrice = this.vm.totalPrice * 100 ? this.vm.totalPrice : this.vm.orderInfo.price * 100
      // 拉起支付弹框
      this.cashierPicker
        .reset()// 内部状态重置
        .setAmount(totalPrice)// 支付金额，单位：分
        .setTradeSummary('')// 订单摘要 (可选，不填则不显示)
        .open();
    }
    // 如果是待付款状态，处理倒计时
    if (this.vm.orderStatus === OrderStatus.PENDING) {
      this.vm.countdownTargetTime(this.vm.laterPayTime)
    }

    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          // 获取支付时间
          this.vm.payTime = new Date();
          // 关闭支付弹框
          this.cashierPicker.close();
          // 已预定
          this.vm.orderStatus = OrderStatus.BOOKED
          // 处理订单数据
          this.vm.handleOrderDetailData()
        }
      }
    );
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  @Styles
  operationStyle(){
    .padding({ top: 12, bottom: 12 })
    .borderRadius(24)
    .flexGrow(1)
  }

  @Builder
  render() {
    Column() {
      // 顶部标题
      this.headerTitleBuilder();
      // 中间滚动区域
      Scroll() {
        Column() {
          // 订单状态
          this.orderStatusBuilder()
          // 详情信息
          this.orderDetailBuilder()
          // 出行人信息
          this.travelPersonBuilder()
        }
        .width('100%')
        .margin({ bottom: 100 })
      }
      .align(Alignment.TopStart)
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      // 底部操作栏
      if (this.vm.orderStatus !== OrderStatus.REFUNDED) {
        this.bottomOperationBuilder();
      }
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.vm.backPage();
      return true
    })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E8FAFF', 0.0], ['#F2F8FA', 0.5], ['#F1F3F5', 1]]
    })
  }

  // 顶部标题
  @Builder
  headerTitleBuilder() {
    Row({ space: 8 }) {
      // 返回按钮
      Image($r('app.media.icon_back')).height(40).width(40)
        .onClick(() => {
          this.vm.backPage();
        })
      Text('订单详情')
        .fontColor('#000000')
        .fontSize(20)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({
      top: BarVM.instance.staBarH + 8,
      left: 16,
      bottom: 8,
      right: 16
    })
  }

  // 订单状态
  @Builder
  orderStatusBuilder() {
    Column({ space: 8 }) {
      Row() {
        Row({ space: 6 }) {
          if (this.vm.orderStatus === OrderStatus.PENDING) {
            Image($r('app.media.ic_exit_time'))
              .width(24)
              .height(24)
          }
          Text(this.vm.orderStatusText)
            .fontColor('#000000')
            .fontSize(20)
            .fontWeight(500)
        }

        if (this.vm.orderStatus === OrderStatus.PENDING) {
          Text(this.vm.countDownTime)
            .fontSize(16)
            .fontColor('#000000')
            .fontWeight(500)
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(this.vm.orderDescription)
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .fontColor(this.vm.orderStatus === OrderStatus.PENDING ? '#FF4A26' : '#000000')
    }.margin({ bottom: 20 })
  }

  // 订单详情
  @Builder
  orderDetailBuilder() {
    Column({ space: 20 }) {
      Row({ space: 10 }) {
        Image($r(this.vm.detailInfo?.scenicImage))
          .width(72)
          .height(54)
          .borderRadius(8)
        Text(this.vm.detailInfo.scenicTitle)
          .fontColor('#333333')
          .fontSize(14)
          .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Top)
      .height(54)

      Row() {
        Text('总计')
          .fontColor('#000000')
          .fontSize(18)
          .fontWeight(500)
        Text(this.vm.orderInfo.price.toString())
          .fontColor('#FF4A26')
          .fontSize(18)
          .fontWeight(500)
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 10 }) {
        Row() {
          Text('订单号：')
            .fontColor('rgba(0,0,0,0.5)')
            .fontSize(12)
          Text(this.vm.detailInfo.scenicOrderNum)
            .fontColor('#000000')
            .fontSize(12)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('下单时间：')
            .fontColor('rgba(0,0,0,0.5)')
            .fontSize(12)
          Text(`${this.vm.detailInfo.scenicCreateDate} ${this.vm.detailInfo.scenicCreateTime}`)
            .fontColor('#000000')
            .fontSize(12)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        if (this.vm.orderStatus === OrderStatus.BOOKED || this.vm.orderStatus === OrderStatus.FINISHED) {
          Row() {
            Text('付款时间：')
              .fontColor('rgba(0,0,0,0.5)')
              .fontSize(12)
            Text(`${this.vm.detailInfo.scenicPayCreateDate} ${this.vm.detailInfo.scenicPayCreateTime}`)
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('支付方式：')
              .fontColor('rgba(0,0,0,0.5)')
              .fontSize(12)
            Text(this.vm.detailInfo.scenicPayType)
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        if (this.vm.orderStatus === OrderStatus.REFUNDED) {
          Row() {
            Text('退款时间：')
              .fontColor('rgba(0,0,0,0.5)')
              .fontSize(12)
            Text(`${this.vm.detailInfo.scenicRefundCreateDate} ${this.vm.detailInfo.scenicRefundCreateTime}`)
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('退款账号：')
              .fontColor('rgba(0,0,0,0.5)')
              .fontSize(12)
            Text(this.vm.detailInfo.scenicRefundAccount)
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('退款金额：')
              .fontColor('rgba(0,0,0,0.5)')
              .fontSize(12)
            Text(this.vm.detailInfo?.scenicRefundPrice?.toString())
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
      }

      Column({ space: 8 }) {
        Text('班期')
          .fontColor('#000000')
          .fontSize(16)
          .fontWeight(500)
          .width('100%')
        Text(this.vm.detailInfo.scenicScheduleDate)
          .fontColor('rgba(0,0,0,0.5)')
          .fontSize(12)
          .width('100%')
      }.width('100%')
    }
    .borderRadius(16)
    .width('100%')
    .padding(12)
    .margin({ bottom: 10 })
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 出行人信息
  @Builder
  travelPersonBuilder() {
    Column({ space: 16 }) {
      Row() {
        Text('出行信息')
          .fontColor('#000000')
          .fontSize(16)
          .fontWeight(500)
        Text(`已选择${this.vm.passengerInfo.length}人`)
          .fontColor('rgba(0,0,0,0.7)')
          .fontSize(14)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      ForEach(this.vm.passengerInfo, (item: PassengerInfo, index: number) => {
        Column({ space: 6 }) {
          Text(item.name)
            .width('100%')
            .fontColor('#000000')
            .fontSize(14)
          Row({ space: 6 }) {
            Text('联系方式')
              .fontColor('#9E9E9E')
              .fontSize(12)
            Text(item.phone)
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%')

          Row({ space: 6 }) {
            Text('证件信息')
              .fontColor('#9E9E9E')
              .fontSize(12)
            Text(item.idNumber && OrderUtil.maskedIdCard(item.idNumber))
              .fontColor('#000000')
              .fontSize(12)
          }.width('100%')
        }.width('100%')
      }, (item: PassengerInfo) => item.toString())

    }
    .borderRadius(16)
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 14,
      bottom: 14
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 底部按钮:根据订单状态不同展示不同的操作按钮
  @Builder
  bottomOperationBuilder() {
    Column({ space: 12 }) {
      // 待付款
      if (this.vm.orderStatus === OrderStatus.PENDING) {
        Row({ space: 16 }) {
          Text('取消订单')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' })
            .onClick(() => {

              promptAction.openCustomDialog({
                builder: () => {
                  this.CustomDialog('确定取消订单？', () => {
                    this.vm.cancelOrder()
                  })
                },
                alignment: DialogAlignment.Center,
                width: '90%'
              })
                .then((id) => {
                  this.vm.dialogId = id
                })
            })
          Text('去付款')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .backgroundColor('#FFFEE231')
            .onClick(() => {
              this.vm.orderTime = new Date();
              // 拉起支付弹框
              this.cashierPicker
                .reset()// 内部状态重置
                .setAmount(this.vm.totalPrice * 100)// 支付金额，单位：分
                .setTradeSummary(this.vm.detailInfo.scenicTitle || '')// 订单摘要 (可选，不填则不显示)
                .open();
            })
        }
        .width('100%')

      }

      // 已取消
      if (this.vm.orderStatus === OrderStatus.CANCEL) {
        Row({ space: 16 }) {
          Text('再次预定')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .backgroundColor('#FFFEE231')
        }
        .width('100%')
        .onClick(() => {
          this.vm.bookAgain()
        })
      }
      // 已预定
      if (this.vm.orderStatus === OrderStatus.BOOKED) {
        Row({ space: 16 }) {
          Text('我要退订')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' })
            .onClick(() => {
              this.vm.applyRefund()
            })
          Text('再次预定')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .backgroundColor('#FFFEE231')
            .onClick(() => {
              this.vm.bookAgain()
            })
        }.width('100%')
      }

      // 已完成
      if (this.vm.orderStatus === OrderStatus.FINISHED) {
        Row({ space: 16 }) {
          Text('报销凭证')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' })
            .onClick(() => {
              this.vm.jumpReimbursementVoucherPage()
            })
          Text('再次预定')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
            .operationStyle()
            .backgroundColor('#FFFEE231')
            .onClick(() => {
              this.vm.bookAgain()
            })
        }.width('100%')
      }

    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: BarVM.instance.aiBarH + 12
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}
