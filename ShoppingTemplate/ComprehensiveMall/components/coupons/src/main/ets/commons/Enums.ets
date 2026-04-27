/** 优惠券状态 */
export enum CouponStatus {
  /** 待使用 */
  AVAILABLE = 0,
  /** 已使用 */
  USED = 1,
  /** 已过期 */
  EXPIRED = 2,
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

export enum ReductionTypes {
  // 满减
  FULL_REDUCTION = 0,
  // 立减
  DIRECT_REDUCTION = 1,
  // 折扣
  DISCOUNT_REDUCTION = 2,
}

export enum SelectTabOption{
  ENABLE,
  DISABLE,
}

