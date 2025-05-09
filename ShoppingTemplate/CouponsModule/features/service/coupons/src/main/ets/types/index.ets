export interface SelectCouponParams {
  // 订单总金额
  totalMoney: number,
  // 已选优惠券ID
  selectId: string,
}

export enum ScenarioStatus {
  // 立马可用
  NOW_USE = 0,
  // 低于满额
  LESS_FULL = 1,
  // 未来使用
  FUTURE_USE = 2,
  // 已使用
  HAS_USED = 3,
  // 已过期
  EXPIRE = 4,
}

/**
 * 与接口设计保持一致
 * 1.优惠券状态
 * 2.核销单状态
 * 3.减免方式
 */
export enum CouponStatus {
  // 生效
  effective = '2',
  // 失效
  lapsed = '3',
}

export enum VerificationStatus {
  // 活动期间正常核销
  NORMAL = '0',
  // 商家取消前已使用
  CANCEL = '1',
}

export enum ReductionTypes {
  // 满减
  FULL_REDUCTION = '0',
  // 立减
  DIRECT_REDUCTION = '1',
  // 折扣
  DISCOUNT_REDUCTION = '2',
}



