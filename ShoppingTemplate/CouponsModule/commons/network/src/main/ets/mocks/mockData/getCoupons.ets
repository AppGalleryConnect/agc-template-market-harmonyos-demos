import { BaseSuccessResponse } from '../../types/BaseSuccessResponse';
import { CouponModel, CouponRule, GetCouponsResp, OffsetInfo } from '../../types/responseTypes/GetCouponsResp';

class CommonRules {
  // 满减-低
  static readonly RULE1_LOW: CouponRule = {
    amountRuleNo: '1',
    amountRuleDesc: '满减',
    discountMode: '0',
    discountType: '0',
    fullAmount: '1000',
    discountAmount: '100',
    discountCoefficient: '',
  }
  // 满减-高
  static readonly RULE1_HIGH: CouponRule = {
    amountRuleNo: '1',
    amountRuleDesc: '满减',
    discountMode: '0',
    discountType: '0',
    fullAmount: '2000',
    discountAmount: '250',
    discountCoefficient: '',
  }
  // 立减
  static readonly RULE2: CouponRule = {
    amountRuleNo: '2',
    amountRuleDesc: '立减',
    discountMode: '0',
    discountType: '1',
    fullAmount: '',
    discountAmount: '15',
    discountCoefficient: '',
  }
  // 折扣
  static readonly RULE3: CouponRule = {
    amountRuleNo: '3',
    amountRuleDesc: '折扣',
    discountMode: '0',
    discountType: '2',
    fullAmount: '',
    discountAmount: '',
    discountCoefficient: '0.8',
  }
}

// 核销单 === 已使用
const OFFSET_INFO: OffsetInfo = {
  offsetID: '',
  couponCollectionTime: '',
  couponOffsetTime: '',
  offsetOrder: '',
  couponStatus: '',
}

/** 生效优惠券 **/
export const getCouponsMock1: BaseSuccessResponse<GetCouponsResp> = {
  code: 0,
  data: {
    total: 13,
    couponsList: [
    // 生效-待使用-活动期间-满减-低
      new CouponModel('1', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE1_LOW, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期间-满减-高
      new CouponModel('100', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE1_HIGH, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期间-立减
      new CouponModel('2', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE2, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期间-折扣
      new CouponModel('3', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE3, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期前-满减
      new CouponModel('4', '优惠券名称', '0', '2030-1-1', '2035-1-1', '2', CommonRules.RULE1_LOW, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期前-立减
      new CouponModel('5', '优惠券名称', '0', '2030-1-1', '2035-1-1', '2', CommonRules.RULE2, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-待使用-活动期前-折扣
      new CouponModel('6', '优惠券名称', '0', '2030-1-1', '2035-1-1', '2', CommonRules.RULE3, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-已使用-满减
      new CouponModel('7', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE1_LOW, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
      // 生效-已使用-立减
      new CouponModel('8', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE2, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
      // 生效-已使用-折扣
      new CouponModel('9', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE3, '-1', '0', '', '', '', '',
        '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
      // 生效-已过期-满减
      new CouponModel('10', '优惠券名称', '0', '2025-1-1', '2025-2-1', '2', CommonRules.RULE1_LOW, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-已过期-立减
      new CouponModel('11', '优惠券名称', '0', '2025-1-1', '2025-2-1', '2', CommonRules.RULE2, '-1', '0', '', '', '',
        '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
      // 生效-已过期-折扣
      new CouponModel('12', '优惠券名称', '0', '2025-1-1', '2025-2-1', '2', CommonRules.RULE3, '-1', '0', '', '', '',
        '', '2', [], [{ key: 0, value: '新用户注册' }], '', ''),
    ],
  },
}

/** 失效且核销优惠券 **/
export const getCouponsMock2: BaseSuccessResponse<GetCouponsResp> = {
  code: 0,
  data: {
    total: 3,
    couponsList: [
    // 失效-已使用-满减
      new CouponModel('13', '优惠券名称', '0', '2025-1-1', '2025-2-1', '3', CommonRules.RULE1_LOW, '-1', '0', '', '',
        '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
      // 失效-已使用-立减
      new CouponModel('14', '优惠券名称', '0', '2025-1-1', '2025-2-1', '3', CommonRules.RULE2, '-1', '0', '', '', '',
        '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
      // 失效-已使用-折扣
      new CouponModel('15', '优惠券名称', '0', '2025-1-1', '2025-2-1', '3', CommonRules.RULE3, '-1', '0', '', '', '',
        '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', OFFSET_INFO),
    ],
  },
}

export const getCouponsMockNull: BaseSuccessResponse<GetCouponsResp> = {
  code: 0,
  data: {
    total: 0,
    couponsList: [],
  },
}