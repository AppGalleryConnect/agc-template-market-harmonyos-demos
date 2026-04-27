import { CounterComponent, CounterType, promptAction } from '@kit.ArkUI';
import { UIContext } from '@kit.ArkUI';
import deviceInfo from '@ohos.deviceInfo';
import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, TValueType, CommonHeader, RandomUtil, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { TourOrderPageVM } from '../viewmodel/TourOrderPageVM'
import {
  TourModel,
  detailRouterParam,
  OrderStatus,
  TravelAggregatedPaymentKey,
  TravelPeopleModel
} from 'common_travel_guide'
import { SelectTravelPeople } from '../components/SelectTravelPeople';

phoneRouterControl.registerPageBuilder(RouterMap.TOUR_ORDER_PAGE, wrapBuilder(TourOrderPageBuilder))

@Builder
export function TourOrderPageBuilder(params?: TValueType) {
  TourOrderPage({ pageParam: params as TourModel })
}

@ComponentV2
export struct TourOrderPage {
  vm: TourOrderPageVM = new TourOrderPageVM()
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  @Param pageParam: TValueType = null
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  @Local orderInfo: string = 'orderInfo'
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
  regPhone(phone:string){
    const phoneRegex = /^1(?:3[0-9]|4[014-9]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$/;
    return phoneRegex.test(phone)
  }

  aboutToAppear(): void {
    // 根据路由传参获取详情数据
    const model: detailRouterParam | null = this.pageParam as detailRouterParam
    this.vm.scenicMockInfo = model.scenicMockInfo;
    this.vm.orderPrice = model.price;
    this.vm.starTime = model.starTime
    this.vm.endTime = model.endTime
    this.vm.scheduleDateCode = model.scheduleDateCode
    this.vm.grownManNum = model.grownManNum || 0
    this.vm.childrenNum = model.childrenNum || 0
    this.vm.contactPhone = model.contactPhone || ''
    // 回显出行人信息
    if (model?.passengerInfo && model.passengerInfo.length) {
      this.vm.getTravelPersonList(model.passengerInfo)
    }
    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          // 获取支付时间
          this.vm.payTime = new Date();
          // 关闭支付弹框
          this.cashierPicker.close();
          // 模拟支付成功或失败
          let random = RandomUtil.getRandomIndex(2)
          random = 0
          if (random === 1) {
            // 已预定
            this.vm.orderStatus = OrderStatus.BOOKED
          } else {
            // 待付款
            this.vm.orderStatus = OrderStatus.PENDING
          }
          // 处理订单数据
          this.vm.handleOrderDetailData()
        }
      }
    );
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  @Builder
  render() {
    Column() {
      // 顶部标题
      CommonHeader({
        title: '订单确认',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      }).padding({ left: 16 })

      // 中间滚动区域
      Scroll() {
        Column() {
          // 景点信息
          this.scenicInfoBuilder()
          // 选择人数
          this.selectPeopleNum()
          // 出行人信息
          SelectTravelPeople({
            routerPeopleList: this.vm.travelPersonList,
            routerPhone: this.vm.contactPhone,
            onConfirm: (list: TravelPeopleModel[], phone: string | number) => {
              this.vm.travelPersonList = list
              this.vm.selectPersonNum = list.length
              this.vm.contactPhone = phone
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 100 })
      }
      .align(Alignment.TopStart)
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      // 底部操作栏
      this.bottomOperationBuilder();
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
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor('#F1F3F5')
    .padding({ top: BarVM.instance.staBarH })
  }

  // 景点信息
  @Builder
  scenicInfoBuilder() {
    Column({ space: 8 }) {
      Text(this.vm.scenicMockInfo?.title)
        .fontColor('#000000')
        .fontSize(16)
        .fontWeight(500)
        .width('100%')

      Row({ space: 12 }) {
        Text(`${this.vm.starTime}出发`)
          .fontColor('rgba(0,0,0,0.4)')
          .fontSize(12)
        Text(`${this.vm.endTime}返程`)
          .fontColor('rgba(0,0,0,0.4)')
          .fontSize(12)
      }.width('100%')
      .justifyContent(FlexAlign.Start)
    }.width('100%').margin({ top: 18, bottom: 22 })
  }

  // 选择人数
  @Builder
  selectPeopleNum() {
    Column({ space: 24 }) {
      Text('选择人数')
        .fontColor('#000000')
        .fontSize(14)
        .fontWeight(500)
        .width('100%')
      Row() {
        Row({ space: 12 }) {
          Text('成人')
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(500)
          Text('12周岁及以上')
            .fontSize(12)
            .fontColor('rgba(0,0,0,0.3)')
            .fontWeight(500)
        }

        CounterComponent({
          options: {
            type: CounterType.LIST,
            numberOptions: {
              min: 0,
              value: this.vm.grownManNum,
              max: 10,
              onChange: (value: number) => {
                this.vm.grownManNum = value
              }
            }
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row({ space: 12 }) {
          Text('儿童')
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(500)
          Text('2-12周岁(不含)')
            .fontSize(12)
            .fontColor('rgba(0,0,0,0.3)')
            .fontWeight(500)
        }

        CounterComponent({
          options: {
            type: CounterType.LIST,
            numberOptions: {
              min: 0,
              value: this.vm.childrenNum,
              max: 10,
              onChange: (value: number) => {
                this.vm.childrenNum = value
              }
            }
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .margin({ bottom: 10 })

  }

  // 底部按钮
  @Builder
  bottomOperationBuilder() {
    // 待付款
    Row({ space: 16 }) {
      Row() {
        Text('在线付')
          .fontColor('rgba(0,0,00.5)')
          .fontSize(12)
        Text('￥')
          .fontColor('#FF4A26')
          .fontSize(12)
        Text(this.vm.totalPrice.toString())
          .fontColor('#FF4A26')
          .fontSize(20)
          .fontWeight(500)
      }

      Text('去付款')
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
        .padding({
          top: 12,
          bottom: 12,
          left: 28,
          right: 28
        })
        .borderRadius(24)
        .backgroundColor('#FFFEE231')
        .onClick(() => {
          if(this.vm.contactPhone) {
            if(!this.regPhone(this.vm.contactPhone.toString())){
              this.showToast('手机号格式错误');
              return
            }
          }
          if (!this.vm.selectPersonNum) {
            promptAction.showToast({
              message: '请选择出行人',
            })
            return
          }
          this.vm.orderTime = new Date();
          // 拉起支付弹框
          this.cashierPicker
            .reset()// 内部状态重置
            .setAmount(this.vm.totalPrice * 100)// 支付金额，单位：分
            .setTradeSummary(this.vm.scenicMockInfo?.title || '')// 订单摘要 (可选，不填则不显示)
            .open();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: BarVM.instance.aiBarH + 12
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}
