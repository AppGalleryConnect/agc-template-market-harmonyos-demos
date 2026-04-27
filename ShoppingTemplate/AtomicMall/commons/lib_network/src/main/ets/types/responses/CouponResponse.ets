import { BaseResponse } from './BaseResponse';

export interface CouponListResp extends BaseResponse {
  total: number;
  couponsList: CouponItem[];
}

export interface CouponItem {
  // ID
  couponID: string;
  // 名称
  couponName: string;
  // 使用限制说明
  usageRestriction: string;
  // 优惠开始时间
  startTime: string;
  // 优惠结束时间
  endTime: string;
  // 优惠券状态: 0-待使用; 1-已使用; 2-已过期
  couponStatus: number;
  // 使用规则
  amountRule: CouponRule;
  // 时间戳
  createdTime: string;
}

export interface CouponRule {
  // 优惠类型: 0-满减; 1-立减; 2-折扣
  discountType: number;
  fullAmount: string;
  discountAmount: string;
  discountCoefficient: string;
}
