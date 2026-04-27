import * as wxopensdk from '@tencent/wechat_open_sdk';
import { Pay } from '@cashier_alipay/cashiersdk';

import { paymentService } from '@kit.PaymentKit';
import { util, HashMap } from '@kit.ArkTS';
import { common, bundleManager, Want } from '@kit.AbilityKit';
import { UIContext } from '@kit.ArkUI';

import { Config } from './common/Config';
import { PaymentCallback, PaymentType } from './common/CustomTypes';
import { wechatEventHandler } from './handlers/WechatEventHandler';
import { WechatPaymentInfo } from './models/WechatPaymentInfo';
import { HuaweiPaymentInfo } from './models/HuaweiPaymentInfo';
import { AlipayPaymentInfo } from './models/AlipayPaymentInfo';

const wechat: wxopensdk.WXApi = wxopensdk.WXAPIFactory.createWXAPI(Config.WECHAT_APP_ID);

class AggregatedPaymentService {

  private paymentCallbacks: HashMap<string, PaymentCallback> = new HashMap();

  private doAllPaymentCallbacks(type: PaymentType, isSuccess: boolean): void {
    this.paymentCallbacks.forEach((cb: PaymentCallback, key: string): void => {
      cb(type, isSuccess, key);
    });
  }

  private initWeChat(): void {
    /**
     * 拦截微信跳回事件，在该事件中触发所有支付回调方法
     */
    wechatEventHandler.registerResponseEvent((response: wxopensdk.PayResp) => {
      this.doAllPaymentCallbacks(PaymentType.WECHAT, response.errCode === wxopensdk.ErrCode.ERR_OK);
    });
    /**
     * 微信 SDK 的 handleWant() 除了用于处理 Want 对象以外，还起到绑定事件处理器的作用。
     *
     * 因此在初始化时率先进行一次无条件绑定，防止 handleWant() 可能没有被调用导
     * 致事件处理器未绑定的情况发生。
     */
    wechat.handleWant({}, wechatEventHandler);
  }

  /**
   * 当 SDK 内部使用显式跳转拉起微信时，微信后续的跳回也会使用显式跳转。若希望对
   * 该事件进行处理，则需要在 EntryAbility 的 onCreate() 和 onNewWant() 方法中
   * 调用 handleWant() 来拦截事件。
   *
   * 注：只有当 openLink() 的方式无法使用时，SDK 才会采用显式跳转。
   *
   * @param want - 应用之间传递信息的数据载体
   */
  public handleWant(want: Want): void {
    wechat.handleWant(want, wechatEventHandler);
  }

  /**
   * 请求跳转至微信支付
   *
   * @param uiContext - UI上下文实例 (用于进一步获取 Ability 上下文实例, SDK内部依赖该实例进行跳转)
   * @param info      - 微信支付所需参数
   * @returns true: 微信拉起成功, false: 微信拉起失败
   */
  public async requestPaymentByWeChat(uiContext: UIContext, info: WechatPaymentInfo): Promise<boolean> {
    try {
      const payRequest: wxopensdk.PayReq = new wxopensdk.PayReq();
      payRequest.id = info.id ?? payRequest.id;
      payRequest.openId = info.openId ?? payRequest.openId;
      payRequest.transaction = info.transaction ?? payRequest.transaction;
      payRequest.signType = info.signType ?? payRequest.signType;
      payRequest.extData = info.extData ?? payRequest.extData;
      payRequest.appId = Config.WECHAT_APP_ID;
      payRequest.callbackAbility = Config.WECHAT_CALLBACK_ABILITY_NAME;
      payRequest.packageValue = Config.WECHAT_PACKAGE_VALUE;
      payRequest.partnerId = info.partnerId;
      payRequest.prepayId = info.prepayId;
      payRequest.nonceStr = info.nonceStr;
      payRequest.timeStamp = info.timeStamp;
      payRequest.sign = info.sign;
      const ctx: Context | undefined = uiContext.getHostContext();
      if (!ctx) {
        throw new Error();
      }
      return await wechat.sendReq(ctx as common.UIAbilityContext, payRequest);
    } catch {
      return false;
    }
  }

  /**
   * 请求跳转至支付宝
   *
   * 以 Mock 数据测试时，不推荐 info.orderInfo 使用空字符串，会导致跳转行为仅仅是跳转，无法在支付宝中触发相关交互
   *
   * @param info         - 支付所需参数
   * @param navPathStack - Navigation 导航控制器（可选），如果传递该参数，当支付宝应用未安装时将自动跳转至 H5 页面进行支付
   * @returns 支付宝没有提供拉起结果的获取方式，因此方法无参返回，统一在支付回调中处理
   */
  public requestPaymentByAliPay(info: AlipayPaymentInfo, navPathStack?: NavPathStack): void {
    const pay: Pay = new Pay();
    if (Config.ALIPAY_APP_ID) {
      pay.registerApp(Config.ALIPAY_APP_ID);
    }
    pay
      .payWithNav(info.orderInfo, true, undefined, navPathStack)
      .then((result: Map<string, string>) => {
        // result 具体内容可参考 -> https://opendocs.alipay.com/open/00iki4?pathHash=eab39489
        let message =
          `resultStatus: ${result.get('resultStatus')} memo: ${result.get('memo')} result: ${result.get('result')}`;
        if (!result || !result.has('resultStatus') || result.get('resultStatus') !== '9000') {
          this.doAllPaymentCallbacks(PaymentType.ALIPAY, false);
        } else {
          this.doAllPaymentCallbacks(PaymentType.ALIPAY, true);
        }
      })
      .catch(() => {
        this.doAllPaymentCallbacks(PaymentType.ALIPAY, false);
      });
  }

  /**
   * 请求拉起华为支付
   *
   * @param uiContext - UI上下文实例 (用于进一步获取 Ability 上下文实例)
   * @param info      - 支付所需参数
   * @returns 华为支付没有提供拉起结果的获取方式，因此方法无参返回，统一在支付回调中处理
   */
  public requestPaymentByHuawei(uiContext: UIContext, info: HuaweiPaymentInfo): void {
    const ctx: Context | undefined = uiContext.getHostContext();
    if (!ctx) {
      this.doAllPaymentCallbacks(PaymentType.HUAWEI, false);
      return;
    }
    paymentService
      .requestPayment(ctx as common.UIAbilityContext, info.orderStr)
      .then(() => {
        this.doAllPaymentCallbacks(PaymentType.HUAWEI, true);
      })
      .catch(() => {
        this.doAllPaymentCallbacks(PaymentType.HUAWEI, false);
      });
  }

  /**
   * 校验微信是否安装
   *
   * @returns true: 已安装, false: 未安装
   */
  public isWeChatInstalled(): boolean {
    return wechat.isWXAppInstalled();
  }

  /**
   * 校验支付宝是否安装
   *
   * @returns true: 已安装, false: 未安装
   */
  public isAlipayInstalled(): boolean {
    return bundleManager.canOpenLink(Config.ALIPAY_SCHEME);
  }

  /**
   * 注册一个通用的支付回调方法，触发条件如下(无论支付成功与否)：
   *
   * 1. 通过微信或支付宝的内置逻辑跳回至当前应用
   * 2. 华为支付流程结束或中断
   *
   * 注：不可以完全依赖回调方法来判断支付结果，例如用户手动切换回当前应用时，则绕开了微信或支付宝内置的跳回逻辑。
   *
   * @param   cb         - 回调方法
   * @returns callbackId - 回调id (用于取消注册时找到目标方法)
   */
  public registerPaymentCallback(cb: PaymentCallback): string {
    const id: string = util.generateRandomUUID(false);
    this.paymentCallbacks.set(id, cb);
    return id;
  }

  /**
   * 注销单个支付回调方法
   *
   * @param callbackId - 回调id
   */
  public unregisterPaymentCallback(callbackId: string): void {
    this.paymentCallbacks.remove(callbackId);
  }

  /**
   * 注销所有支付回调方法
   */
  public unregisterAllPaymentCallbacks(): void {
    this.paymentCallbacks.clear();
  }

  constructor() {
    this.initWeChat();
  }
}

export const aggregatedPaymentService: AggregatedPaymentService = new AggregatedPaymentService();
