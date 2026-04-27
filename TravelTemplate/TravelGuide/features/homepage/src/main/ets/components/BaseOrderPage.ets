import deviceInfo from '@ohos.deviceInfo';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TValueType, RouterMap, UserInfo } from 'common';
import {
  OrderStatus,
  OrderType,
  TravelAggregatedPaymentKey,
  TravelPeopleModel,
  baseToast,
  TicketReturnDetailListModel,
  PlaneReturnDetailListModel,
  PlaneDetailListModel
} from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { RealNameAuthPageBuilder } from 'module_auth';
import { TicketPendingPaymentVM } from '../viewmodel/TicketPendingPaymentVM';
import { SelectTravelPeople } from './SelectTravelPeople';

@ComponentV2
export struct BaseOrderPage {
  // 泛型参数，用于接收不同类型的订单数据
  @Param pageParam: TValueType = null
  @Param orderType: OrderType = OrderType.TRAIN
  @Param tradeSummary: string = ''
  @Param expiredMessage: string = ''
  // 抽象方法，由子类实现
  @BuilderParam renderTripInfo: () => void
  @BuilderParam renderPriceInfo: () => void
  @BuilderParam renderAdditionalInfo?: () => void
  // 回调方法，由子类实现
  @Event getReturnPrice: () => string
  @Event onPeopleListChange: (list: TravelPeopleModel[]) => void
  @Event jumpToPendingPaymentPage: (vm: TicketPendingPaymentVM) => void
  // 公共状态
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
  @Local phoneText: string = ''
  @Local peopleList: TravelPeopleModel[] = []
  @Local orderInfo: string = 'orderInfo'
  // 公共实例
  vm: TicketPendingPaymentVM = new TicketPendingPaymentVM()
  private uiContext: UIContext = this.getUIContext()
  private navPathStack: NavPathStack = new NavPathStack()
  // 支付相关
  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // 根据支付类型处理支付请求
      if (type === PaymentType.ALIPAY) {
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: this.orderInfo }, this.navPathStack);
      } else if (type === PaymentType.HUAWEI) {
        if (deviceInfo.marketName === 'emulator') {
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
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
        this.vm.orderInfo.status = OrderStatus.PENDING;
        this.vm.isPayment = false
        this.jumpToPendingPaymentPage(this.vm);
      }
    });

  private showRealNameAuthDialog() {
    baseToast.show({
      type: 'dialog',
      hasTitle: '实名认证提醒',
      message: '出行订单需要真人实名认证信息确认',
      confirmColor: $r('sys.color.font_primary'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmAction: () => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.REAL_NAME_AUTH_PAGE,
          builder: wrapBuilder(RealNameAuthPageBuilder),
          onPop: (popInfo: PopInfo) => {
            if (popInfo.result) {
              this.userInfo.isAuthentication = '1';
            } else {
              this.userInfo.isAuthentication = '0';
            }
          }
        });
        baseToast.hide();
      },
      cancelAction: () => {
        baseToast.hide();
      },
    });
  }

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  countFieldValues(array: TravelPeopleModel[]): number {
    return array.filter(item => item.isCheck === true).length;
  }

  aboutToAppear(): void {
    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          this.cashierPicker.close();
          this.vm.orderInfo.status = OrderStatus.ISSUED;
          this.vm.isPayment = true
          this.jumpToPendingPaymentPage(this.vm);
        }
      }
    );
    this.peopleList = (this.pageParam as PlaneDetailListModel)?.peopleList ||
    (this.pageParam as TicketReturnDetailListModel)?.ticketGo?.peopleList ||
    (this.pageParam as PlaneReturnDetailListModel)?.planeGo?.peopleList
  }

  aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage();
      return true;
    })
    .backgroundColor($r('sys.color.background_secondary'));
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
                phoneRouterControl.popPage();
                return true;
              });
            Row() {
              Text('订单确认')
                .fontSize(20)
                .fontColor('#000');
            }
            .margin({ left: 8 });
          }
          .width('100%')
          .margin({ bottom: 30 });
        }
        .padding({ top: 44 });

        Column() {
          // 渲染行程信息，由子类实现
          this.renderTripInfo();

          // 旅客选择组件
          SelectTravelPeople({
            routerPeopleList: this.peopleList,
            onConfirm: (list: TravelPeopleModel[], phone: string | number) => {
              this.peopleList = list;
              this.onPeopleListChange(list);
            }
          });

          // 发票信息
          Column() {
            Text('发票')
              .fontSize(16)
              .fontColor('#333333');
            Text('电子发票在一年内可至订单详情申请')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 14, bottom: 4 });
            Text('24小时内开具')
              .fontSize(12)
              .fontColor('#333333')
              .opacity(0.4);
          }
          .borderRadius(16)
          .width('100%')
          .backgroundColor('#fff')
          .padding(12)
          .alignItems(HorizontalAlign.Start);

          // 额外信息，可选，由子类实现
          if (this.renderAdditionalInfo) {
            this.renderAdditionalInfo();
          }
        }
      }
      .layoutWeight(1)
      .padding(16);

      // 底部支付栏
      Row() {
        Row() {
          Text('在线付')
            .fontSize(12)
            .fontColor('#000')
            .opacity(0.5);
          Text('¥')
            .fontSize(12)
            .fontColor('#FF4A26');
          Text(this.getReturnPrice())
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF4A26');
        }
        .height(22)
        .alignItems(VerticalAlign.Bottom)

        Row() {
          Text('提交订单')
            .fontSize(14);
        }
        .enabled(this.peopleList.length > 0 ? true : false)
        .backgroundColor(this.peopleList.length > 0 ? '#FFE431' : '#f3f3f3')
        .borderRadius(24)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(96)
        .height(40)
        .onClick(() => {
          let regex = /^1[3-9]\d{9}$/;
          if (this.phoneText && !regex.test(this.phoneText)) {
            this.showToast('手机号格式错误');
          } else {
            if (this.vm.getIsExpirt()) {
              if (this.userInfo.isAuthentication === '1') {
                this.cashierPicker
                  .reset() // 内部状态重置
                  .setAmount(Number(this.getReturnPrice()) * 100) // 支付金额，单位：分
                  .setTradeSummary(this.tradeSummary) // 订单摘要
                  .open();
              } else {
                this.showRealNameAuthDialog()
              }
            } else {
              this.showToast(this.expiredMessage);
            }
          }
        });
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#fff')
      .justifyContent(FlexAlign.SpaceBetween);
    }
  }
}