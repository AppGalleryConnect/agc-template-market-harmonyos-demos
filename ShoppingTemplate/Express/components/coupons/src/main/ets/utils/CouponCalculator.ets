import { ReductionTypes, ScenarioStatus, CouponStatus } from '../commons/Enums';
import { CouponItem } from '../commons/Types';

/**
 * 获取优惠减免金额
 */
export function getReduceAmount(coupon: CouponItem, orderMoney: number): number {
  const precision = 1000;
  if (coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
    return (
      ((1 * precision -
        Number(coupon.amountRule.discountCoefficient) * precision) *
        orderMoney) /
        precision
    );
  }
  return Number(coupon.amountRule.discountAmount);
}

/**
 * 根据实付金额和优惠券，反向计算订单原价
 * @param coupon 优惠券对象
 * @param paidAmount 实付金额（减免后的金额）
 */
export function getOriginalAmount(coupon: CouponItem, paidAmount: number): number {
  const precision = 1000;
  // 1. 折扣券反推
  if (coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
    const coefficient = Number(coupon.amountRule.discountCoefficient);
    // 防止除以0的极端情况
    if (coefficient <= 0) {
      return paidAmount;
    }
    // 公式：原价 = 实付 / 折扣系数
    // 使用 precision 保持精度计算
    return (paidAmount * precision) / (coefficient * precision);
  }
  // 2. 满减/固定金额券反推
  // 公式：原价 = 实付 + 抵扣金额
  const discountAmount = Number(coupon.amountRule.discountAmount || 0);
  return (paidAmount * precision + discountAmount * precision) / precision;
}

/**
 * 获取减免方式说明
 */
export function getReduceDesc(coupon: CouponItem): string {
  switch (coupon.amountRule.discountType) {
    case ReductionTypes.FULL_REDUCTION:
      return '消费金额达到指定标准,即可享受减免';
    case ReductionTypes.DIRECT_REDUCTION:
      return '消费者直接享受相应减免';
    case ReductionTypes.DISCOUNT_REDUCTION:
      return '按指定折扣享受相应减免';
    default:
      return '';
  }
}

/**
 * 获取距离优惠日天数
 */
export function getReduceDays(coupon: CouponItem): string {
  const currentDate = new Date();
  const targetDate = new Date(coupon.startTime);
  const timeDifference = targetDate.getTime() - currentDate.getTime();
  const daysDifference = Math.ceil(timeDifference / (1000 * 3600 * 24));
  if (daysDifference < 7) {
    return `${daysDifference} 天`;
  } else if (daysDifference < 30) {
    const weeks = Math.floor(daysDifference / 7);
    return `${weeks} 周`;
  } else if (daysDifference < 365) {
    const months = Math.floor(daysDifference / 30);
    return `${months} 月`;
  } else {
    const years = Math.floor(daysDifference / 365);
    return `${years} 年`;
  }
}

/**
 * 获取优惠券场景状态
 */
export function getScenarioStatus(coupon: CouponItem, orderMoney: number): ScenarioStatus {
  if (coupon.couponStatus === CouponStatus.USED) {
    return ScenarioStatus.HAS_USED;
  }
  if (coupon.couponStatus === CouponStatus.EXPIRED) {
    return ScenarioStatus.EXPIRE;
  }
  const end = new Date(coupon.endTime + ' 23:59:59').getTime();
  const now = new Date().getTime();
  if (end < now) {
    return ScenarioStatus.EXPIRE;
  }
  if (!orderMoney) {
    return ScenarioStatus.NOW_USE;
  }
  const start = new Date(coupon.startTime + ' 0:0:0').getTime();
  if (now < start) {
    return ScenarioStatus.FUTURE_USE;
  }
  if (orderMoney < Number(coupon.amountRule.fullAmount)) {
    return ScenarioStatus.LESS_FULL;
  }
  return ScenarioStatus.NOW_USE;
}
