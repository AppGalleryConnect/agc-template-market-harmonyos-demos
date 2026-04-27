
/**
 * 微信支付所需的相关参数
 *
 * 可参考 -> https://pay.weixin.qq.com/doc/v3/merchant/4013070347
 */
export interface WechatPaymentInfo {
  id?: number;           // 保留字段
  openId?: string;       // 保留字段
  transaction?: string;  // 保留字段
  signType?: string;     // 保留字段
  extData?: string;      // 保留字段
  partnerId: string;     // 商户号 (服务器向微信支付下单时使用的 mchid 字段)
  prepayId: string;      // 预支付交易会话标识 (服务器向微信支付下单后从接口获取的 prepay_id 字段)
  nonceStr: string;      // 随机字符串 (不长于32位)
  timeStamp: string;     // Unix时间戳 (仅支持秒级时间戳)
  sign: string;          // 签名 (使用 appId、timeStamp、nonceStr、prepayId 以及商户 API 证书私钥生成的RSA签名值)
}
