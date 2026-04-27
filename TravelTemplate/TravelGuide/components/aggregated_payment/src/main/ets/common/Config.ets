

export class Config {
  /**
   * 在微信开放平台申请的 AppId
   *
   * 避免使用空字符串进行测试，这会导致应用向微信跳转的行为仅仅是跳转，无法触发任何与支付相关的交互或回调事件
   */
  public static readonly WECHAT_APP_ID: string = 'WECHAT_APP_ID';

  /**
   * 从微信跳回至发起应用时使用的 ability 名称
   */
  public static readonly WECHAT_CALLBACK_ABILITY_NAME: string = 'EntryAbility';

  /**
   * 微信支付 API 约定的固定值，用于支付请求参数中的 packageValue 字段
   */
  public static readonly WECHAT_PACKAGE_VALUE: string = 'Sign=WXPay';

  /**
   * 支付宝 APP 对应的 Scheme
   *
   * 由于 Alipay SDK 没有提供用于校验其应用是否安装的方式，因此需要依赖该字段自行实现校验
   */
  public static readonly ALIPAY_SCHEME: string = 'alipays://';

  /**
   * 在支付宝开放平台申请的 AppId
   *
   * 该字段可以为空，但基于 AppId 的防黑产相关安全能力将不会生效
   */
  public static readonly ALIPAY_APP_ID: string = '';
}
