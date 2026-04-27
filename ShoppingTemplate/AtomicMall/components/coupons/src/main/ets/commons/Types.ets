import { CouponStatus, ReductionTypes } from './Enums';

export interface OnPopParams {
  /** 减免金额 */
  reduce: number;

  /** 选择优惠券ID */
  selectId: string;
}

/** 优惠券数据模型 */
export interface CouponItem {
  /** 优惠券 ID */
  couponID: string;

  /** 优惠券名称 */
  couponName: string;

  /** 使用限制说明（如"全平台可用"、"仅限会员可用"） */
  usageRestriction: string;

  /** 优惠开始时间（YYYY-MM-DD） */
  startTime: string;

  /** 优惠结束时间（YYYY-MM-DD） */
  endTime: string;

  /** 创建时间 */
  createdTime: string;

  /** 优惠券状态 */
  couponStatus: CouponStatus;

  /** 使用规则 */
  amountRule: CouponRule;
}

/** 优惠券使用规则 */
export interface CouponRule {
  /** 优惠类型: 0-满减; 1-立减; 2-折扣 */
  discountType: ReductionTypes;

  /** 满减门槛金额 */
  fullAmount: string;

  /** 优惠金额（满减/立减场景） */
  discountAmount: string;

  /** 折扣系数（折扣场景，0-1 之间） */
  discountCoefficient: string;
}

export interface CouponsControllerType {
  couponList: CouponItem[]
  isLoading: boolean
  themeColor: ResourceColor
  selectedId: string
  reduce: number
  totalMoney: number
  onLoadCoupons?: () => Promise<CouponItem[]>;
  onClaimCoupon?: (couponId: string) => Promise<CouponItem[] | null>;
  onAfterUse?: (couponId: string) => Promise<CouponItem[] | null>;
  onUseNow?: (couponId: string) => void;
  onConfirm?: (params: OnPopParams) => void;
  closeSheet?: () => void;

  select(uiContext: UIContext): Promise<void>

  loadCoupons(): Promise<void>

  claimCoupon(couponId: string): Promise<void>

  useNow(couponId: string): void

  toggleSelect(coupon: CouponItem): void

  confirm(): Promise<void>
}