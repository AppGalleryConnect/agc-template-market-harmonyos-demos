import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants, OrderTabBarType } from 'constant';
import { Order } from 'type';
import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { https, UpdateOrderRequest } from 'network';
import { AppStorageBank, Logger } from 'util';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@ComponentV2
export struct OrderFooter {
  vm: OrderPageVM = OrderPageVM.instance;
  @Param @Require order: Order;
  @Consumer('orderTabIndex') orderTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  async openCashierPicker() {
    const cashierPicker: CashierPicker = new CashierPicker(this.getUIContext())
      .onRealPayment(async (type: PaymentType) => {
        try {
          if (type === PaymentType.HUAWEI) {
            aggregatedPaymentService.requestPaymentByHuawei(this.getUIContext(), { orderStr: '' });
          } else if (type === PaymentType.ALIPAY) {
            aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: '' });
          } else if (type === PaymentType.WECHAT) {
            const success = await aggregatedPaymentService.requestPaymentByWeChat(
              this.getUIContext() as UIContext, {
                partnerId: '',
                prepayId: '',
                nonceStr: '',
                timeStamp: '',
                sign: '',
              });
            if (!success) {
              this.getUIContext().getPromptAction().showToast({ message: '微信拉起失败' });
            }
          }
        } catch (err) {
          Logger.info('pay fail with reason ' + JSON.stringify(err));
        }
      })
      .onWillDismiss((reason: DismissReason) => {
        if (reason !== DismissReason.TOUCH_OUTSIDE) {
          cashierPicker.close();
        }
      });

    aggregatedPaymentService.registerPaymentCallback(
      async (_type: PaymentType, isSuccess: boolean) => {
        if (!isSuccess) {
          ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        }
        let desIndex: number = this.order.orderType === 1 ? OrderTabBarType.TO_SHIP : OrderTabBarType.TO_USE;
        this.order.orderStatus = desIndex;
        this.vm.orderList.map((item => {
          if (item.orderSn === this.order.orderSn) {
            item.orderStatus = desIndex;
          }
        }));
        AppStorageBank.updateOrder(this.vm.orderList);
        await https.updateOrder({ orderSn: this.order.orderSn, orderStatus: 2 } as UpdateOrderRequest);
        cashierPicker.close();
      },
    );

    cashierPicker
      .reset()
      .setAmount(this.order.amount * 100)
      .setTradeSummary(this.order.orderName)
      .open();
  }

  build() {
    Row() {
      Button('取消订单', { type: ButtonType.Normal })
        .width(150)
        .height(40)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_primary'))
        .border({ width: 1, color: $r('sys.color.comp_divider'), radius: $r('sys.float.corner_radius_level4') })
        .margin({ bottom: 16, right: 16 })
        .onClick(() => {
          this.vm.orderList.map((item => {
            if (item.orderSn === this.order.orderSn) {
              this.order.orderStatus = OrderTabBarType.CANCEL;
              item.orderStatus = OrderTabBarType.CANCEL;
            }
          }));
          AppStorageBank.updateOrder(this.vm.orderList);
          this.mainPathStack.pop(this.order);
        });

      Button('立即支付', { type: ButtonType.Normal })
        .width(150)
        .height(40)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.keyword_type_font_color'))
        .border({ width: 0, radius: $r('sys.float.corner_radius_level4') })
        .margin({ bottom: 16, left: 16 })
        .onClick(() => {
          this.openCashierPicker();
        });
    }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Center);
  }
}
