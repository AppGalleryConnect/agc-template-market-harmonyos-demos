import { CouponItem, CouponRule } from '../../types/responses/CouponResponse';

// ── 公共折扣规则 ────────────────────────────────────────────
const RULE_FULL_50: CouponRule = {
  discountType: 0,
  fullAmount: '300',
  discountAmount: '50',
  discountCoefficient: '',
};

const RULE_FULL_100: CouponRule = {
  discountType: 0,
  fullAmount: '500',
  discountAmount: '100',
  discountCoefficient: '',
};

const RULE_FULL_200: CouponRule = {
  discountType: 0,
  fullAmount: '800',
  discountAmount: '200',
  discountCoefficient: '',
};

const RULE_DIRECT_20: CouponRule = {
  discountType: 1,
  fullAmount: '',
  discountAmount: '20',
  discountCoefficient: '',
};

const RULE_DIRECT_30: CouponRule = {
  discountType: 1,
  fullAmount: '',
  discountAmount: '30',
  discountCoefficient: '',
};

const RULE_DISCOUNT_80: CouponRule = {
  discountType: 2,
  fullAmount: '',
  discountAmount: '',
  discountCoefficient: '0.8',
};

const RULE_DISCOUNT_90: CouponRule = {
  discountType: 2,
  fullAmount: '',
  discountAmount: '',
  discountCoefficient: '0.9',
};

export class MockCouponData {
  /**
   * 全量优惠券列表
   * couponStatus='0' → 待使用; couponStatus='1' → 已使用; couponStatus='2' → 已过期
   */
  public static readonly COUPON_LIST: CouponItem[] = [
    // ── 待使用·活动期间 ──────────────────────────────
    {
      couponID: 'c_001',
      couponName: '新人专享满减券',
      usageRestriction: '仅限新用户可用',
      startTime: '2025-01-01',
      endTime: '2035-12-31',
      couponStatus: 0,
      amountRule: RULE_FULL_50,
      createdTime: '2025-01-01',
    },
    {
      couponID: 'c_002',
      couponName: '周末满减特惠',
      usageRestriction: '全平台可用',
      startTime: '2025-03-01',
      endTime: '2035-12-31',
      couponStatus: 0,
      amountRule: RULE_FULL_100,
      createdTime: '2025-03-01',
    },
    {
      couponID: 'c_003',
      couponName: '周年庆促销立减券',
      usageRestriction: '仅限指定商品可用',
      startTime: '2025-01-01',
      endTime: '2035-12-31',
      couponStatus: 0,
      amountRule: RULE_DIRECT_20,
      createdTime: '2025-01-01',
    },
    {
      couponID: 'c_004',
      couponName: '品牌八折优惠券',
      usageRestriction: '仅限指定品牌商品可用',
      startTime: '2025-06-01',
      endTime: '2035-12-31',
      couponStatus: 0,
      amountRule: RULE_DISCOUNT_80,
      createdTime: '2025-06-01',
    },
    // ── 待使用·活动期前（未到开始时间）─────────────────
    {
      couponID: 'c_005',
      couponName: '双十一大促满减券',
      usageRestriction: '全平台可用',
      startTime: '2030-11-01',
      endTime: '2030-11-30',
      couponStatus: 0,
      amountRule: RULE_FULL_200,
      createdTime: '2025-10-01',
    },
    {
      couponID: 'c_006',
      couponName: '年末感恩九折券',
      usageRestriction: '全平台可用',
      startTime: '2030-12-01',
      endTime: '2030-12-31',
      couponStatus: 0,
      amountRule: RULE_DISCOUNT_90,
      createdTime: '2025-11-01',
    },
    // ── 已使用 ──────────────────────────────────────
    {
      couponID: 'c_007',
      couponName: '春节满减红包券',
      usageRestriction: '全平台可用',
      startTime: '2025-01-01',
      endTime: '2035-12-31',
      couponStatus: 1,
      amountRule: RULE_FULL_50,
      createdTime: '2026-01-10',
    },
    {
      couponID: 'c_008',
      couponName: '会员立减专享',
      usageRestriction: '仅限指定商品可用',
      startTime: '2025-01-01',
      endTime: '2035-12-31',
      couponStatus: 1,
      amountRule: RULE_DIRECT_30,
      createdTime: '2026-01-15',
    },
    // ── 已过期 ────────────────────────────────────
    {
      couponID: 'c_009',
      couponName: '限时满减特惠',
      usageRestriction: '全平台可用',
      startTime: '2025-01-01',
      endTime: '2025-06-30',
      couponStatus: 2,
      amountRule: RULE_FULL_100,
      createdTime: '2025-01-01',
    },
    {
      couponID: 'c_010',
      couponName: '夏日折扣券',
      usageRestriction: '全平台可用',
      startTime: '2025-07-01',
      endTime: '2025-08-31',
      couponStatus: 2,
      amountRule: RULE_DISCOUNT_80,
      createdTime: '2025-07-01',
    },
  ];

  /**
   * 生成一张可领取的优惠券（领取接口使用）
   */
  public static newClaimableCoupon(couponId: string): CouponItem {
    return {
      couponID: couponId,
      couponName: '新领优惠券',
      usageRestriction: '全平台可用',
      startTime: '2026-01-01',
      endTime: '2036-12-31',
      couponStatus: 0,
      amountRule: RULE_FULL_50,
      createdTime: '2026-01-01',
    };
  }
}
