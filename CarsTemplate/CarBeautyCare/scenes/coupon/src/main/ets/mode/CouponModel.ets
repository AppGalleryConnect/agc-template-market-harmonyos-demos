// 店铺信息属性
@ObservedV2
export class CouponModel {
  name: string; //优惠券名称
  couponNumber: number; //优惠券金额
  threshold: string; //使用门槛
  channel: string; //使用渠道
  expirationTime: string; //到期时间
  id: number; //唯一标识符
  @Trace used: boolean; //是否使用
  overdue: boolean; //是否过期
  detailList: string[]; //使用说明
  @Trace hasPickUp: boolean = false; // 是否领取


  constructor(name: string, couponNumber: number, threshold: string, channel: string, expirationTime: string,
    id: number, used: boolean, overdue: boolean, detailList: string[]) {
    this.name = name;
    this.couponNumber = couponNumber;
    this.threshold = threshold;
    this.channel = channel;
    this.expirationTime = expirationTime;
    this.id = id;
    this.used = used;
    this.overdue = overdue;
    this.detailList = detailList;
  }
}

export const COUPON_DEFAULT: CouponModel[] = [
  new CouponModel(
    '小保养券（新人专享）',
    299,
    '满¥99可用',
    '使用渠道：小程序',
    '2025.06.30 23:59到期',
    101,
    false,
    false,
    ['1、请在app或小程序下单，并提前预约。', '2、仅限服务项目为更换机油',
      '3、此券仅适用于机油和机油过滤及保养工时费抵扣。'],

  ),
  new CouponModel(
    '新人无门槛券',
    99,
    '满¥99可用',
    '',
    '2025.07.30 23:59到期',
    102,
    false,
    false,
    ['1、请在app或小程序下单，并提前预约。', '2、仅限服务项目为更换机油',
      '3、此券仅适用于机油和机油过滤及保养工时费抵扣。']  ),
  new CouponModel(
    '新人无门槛券',
    99,
    '满¥99可用',
    '',
    '2025.08.30 23:59到期',
    103,
    false,
    false,
    ['1、请在app或小程序下单，并提前预约。', '2、仅限服务项目为更换机油',
      '3、此券仅适用于机油和机油过滤及保养工时费抵扣。']  ),

];

export const COUPON_SHOW: CouponModel[] = [
  new CouponModel(
    '小保养券',
    299,
    '满¥99可用',
    '使用渠道：元服务',
    '2025.06.30 23:59到期',
    104,
    false,
    false,
    ['1、请在app或小程序下单，并提前预约。', '2、仅限服务项目为更换机油',
      '3、此券仅适用于机油和机油过滤及保养工时费抵扣。']
  ),


];
