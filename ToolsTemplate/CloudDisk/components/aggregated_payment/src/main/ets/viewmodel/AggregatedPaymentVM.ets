import { Pay } from '@cashier_alipay/cashiersdk';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { ChannelType, WxExtraInfo } from '../common/Constant';

@ObservedV2
export class AggregatedPaymentVM {
  private static _instance: AggregatedPaymentVM;

  public static get instance() {
    if (!AggregatedPaymentVM._instance) {
      AggregatedPaymentVM._instance = new AggregatedPaymentVM();
    }
    return AggregatedPaymentVM._instance;
  }

  aliPay(paySuccessEvent: (type: ChannelType) => void, orderStr: string | WxExtraInfo) {
    new Pay().pay(String(orderStr), true).then((result) => {
      let message =
        `resultStatus: ${result.get('resultStatus')} memo: ${result.get('memo')} result: ${result.get('result')}`;

      if (result.get('resultStatus') === '9000') {
        message = '支付成功';
        paySuccessEvent(ChannelType.ALI_PAY);
      } else {
        promptAction.showToast({
          message: message,
          duration: 2000,
        });
      }
    }).catch((error: BusinessError) => {
      console.log(error.message);
      promptAction.showToast({
        message: error.message,
        duration: 2000,
      });
    });
  }

  async weChatPay(payReq: string | WxExtraInfo, appId: string) {
    // 根据APP_ID创建支付API
    const wxApi = wxopensdk.WXAPIFactory.createWXAPI(appId);

    let req = new wxopensdk.PayReq;
    req.partnerId = (payReq as WxExtraInfo).partnerId;
    req.appId = (payReq as WxExtraInfo).appId;
    req.packageValue = (payReq as WxExtraInfo).packageValue;
    req.prepayId = (payReq as WxExtraInfo).prepayId;
    req.nonceStr = (payReq as WxExtraInfo).nonceStr;
    req.timeStamp = (payReq as WxExtraInfo).timeStamp;
    req.sign = (payReq as WxExtraInfo).sign;
    req.extData = (payReq as WxExtraInfo).extData;

    await wxApi.sendReq(getContext(this) as common.UIAbilityContext, req);
  }

  huaweiPay(context: common.UIAbilityContext, orderStr: string | WxExtraInfo,
    paySuccessEvent: (type: ChannelType) => void) {
    paymentService.requestPayment(context, String(orderStr)).then(() => {
      paySuccessEvent(ChannelType.HUAWEI_PAY);
    }).catch((error: BusinessError) => {
      paySuccessEvent(ChannelType.HUAWEI_PAY);
    });
  }
}