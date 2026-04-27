import { CashierPicker, PaymentType, aggregatedPaymentService } from 'aggregated_payment';
import { UtilLog } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { OrderActionReq } from '../model/IRequest';
import { ContextUtil } from './ContextUtil';
import { RouterModule } from '../router/RouterModule';
import { Parcel } from '../model/Parcel';


export class OrderUtil {
  private static paymentCallbackId: string = '';
  /**
   * 立即支付
   * @param param
   */
  public static handleImmediatePayment(param: OrderActionReq) {
    if (OrderUtil.paymentCallbackId) {
      aggregatedPaymentService.unregisterPaymentCallback(OrderUtil.paymentCallbackId);
    }
    const order = param.data as Parcel;
    const cashierPicker: CashierPicker = new CashierPicker(ContextUtil.globalUIContext)
      .onRealPayment(async (type: PaymentType) => {
        await OrderUtil._startPayment(type);
      })
      .onWillDismiss((reason: DismissReason) => {
        if (reason !== DismissReason.TOUCH_OUTSIDE) {
          cashierPicker.close();
        }
      });
    const paymentCallback = async (_type: PaymentType, isSuccess: boolean) => {
      if (isSuccess) {
        param.callback?.();
        cashierPicker.close();
      } else {
        ToastDialog.showToast({ message: '本地调试阶段，模拟支付成功回调' });
        // 模拟成功
        param.callback?.();
        cashierPicker.close();
      }
    }
    OrderUtil.paymentCallbackId = aggregatedPaymentService.registerPaymentCallback(paymentCallback);
    cashierPicker
      .reset()
      .setAmount(order.price * 100)
      .open();
  }


  private static async _startPayment(type: PaymentType) {
    // todo: 根据支付类型向服务器请求支付所需参数
    try {
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, RouterModule.stack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        aggregatedPaymentService.requestPaymentByHuawei(ContextUtil.globalUIContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(ContextUtil.globalUIContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: '',
          });
        if (!isWeChatOpenSuccess) {
          ToastDialog.showToast({ message: '微信拉起失败' })
        }
      }
    } catch (err) {
      UtilLog.error('[OrderSubmitVM]', 'start payment failed. error: ' + JSON.stringify(err));
    }
  }
}
