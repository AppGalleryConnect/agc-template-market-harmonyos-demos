/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { Pay } from '@cashier_alipay/cashiersdk';
import * as wxOpenSdk from '@tencent/wechat_open_sdk';
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

  aliPay(paySuccessEvent: (type: ChannelType) => void,
    payFailEvent: (type: ChannelType) => void,
    orderStr: string | WxExtraInfo) {
    new Pay().pay(String(orderStr), true).then((result) => {
      if (result.get('resultStatus') === '9000') {
        paySuccessEvent(ChannelType.ALI_PAY);
      } else {
        payFailEvent(ChannelType.ALI_PAY);
      }
    }).catch(() => {
      payFailEvent(ChannelType.ALI_PAY);
    });
  }

  async weChatPay(_paySuccessEvent: (type: ChannelType) => void,
    payFailEvent: (type: ChannelType) => void,
    payReq: string | WxExtraInfo, appId: string,
    context: UIContext) {
    // 根据APP_ID创建支付API
    const wxApi = wxOpenSdk.WXAPIFactory.createWXAPI(appId);
    let req = new wxOpenSdk.PayReq;
    req.partnerId = (payReq as WxExtraInfo).partnerId;
    req.appId = (payReq as WxExtraInfo).appId;
    req.packageValue = (payReq as WxExtraInfo).packageValue;
    req.prepayId = (payReq as WxExtraInfo).prepayId;
    req.nonceStr = (payReq as WxExtraInfo).nonceStr;
    req.timeStamp = (payReq as WxExtraInfo).timeStamp;
    req.sign = (payReq as WxExtraInfo).sign;
    req.extData = (payReq as WxExtraInfo).extData;
    await wxApi.sendReq(context.getHostContext() as common.UIAbilityContext, req);
    payFailEvent(ChannelType.WECHAT_PAY);
  }

  huaweiPay(paySuccessEvent: (type: ChannelType) => void,
    _payFailEvent: (type: ChannelType) => void,
    context: common.UIAbilityContext, orderStr: string | WxExtraInfo) {
    paymentService.requestPayment(context, String(orderStr)).then(() => {
      paySuccessEvent(ChannelType.HUAWEI_PAY);
    }).catch(() => {
      paySuccessEvent(ChannelType.HUAWEI_PAY);
    });
  }
}