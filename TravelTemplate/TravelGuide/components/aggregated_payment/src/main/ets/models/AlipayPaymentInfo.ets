
/**
 * 支付宝只需要提供 orderInfo 一个字段
 *
 * 可参考 -> https://opendocs.alipay.com/open/cd12c885_alipay.trade.app.pay?scene=20&pathHash=ab686e33
 */
export interface AlipayPaymentInfo {
  orderInfo: string;
}
