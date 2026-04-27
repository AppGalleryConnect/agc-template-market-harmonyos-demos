
/**
 * 华为支付只需要提供 orderStr 一个字段
 *
 * 可参考 -> https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-payment-process#section126982401468
 */
export interface HuaweiPaymentInfo {
  orderStr: string;
}
