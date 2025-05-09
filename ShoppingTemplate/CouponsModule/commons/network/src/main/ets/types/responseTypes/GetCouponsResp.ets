export interface GetCouponsResp {
  total: number
  couponsList: CouponItem[]
}

export class CouponModel implements CouponItem {
  couponID: string
  couponName: string
  validityPeriodMode: string
  startTime: string
  endTime: string
  status: string
  amountRule: CouponRule
  distributionQuantity: string
  repeatedPickup: string
  categoryGroup: string
  brandGroup: string
  catalogGroup: string
  productGroup: string
  recipientLimits: string
  specifiedSubGroup: KeyValue[]
  specifiedPickupScenario: KeyValue[]
  createdTime: string
  lastUpdateTime: string
  offsetInfo?: OffsetInfo

  constructor(couponID: string, couponName: string, validityPeriodMode: string, startTime: string, endTime: string,
    status: string, amountRule: CouponRule, distributionQuantity: string, repeatedPickup: string, categoryGroup: string,
    brandGroup: string, catalogGroup: string, productGroup: string, recipientLimits: string,
    specifiedSubGroup: KeyValue[], specifiedPickupScenario: KeyValue[], createdTime: string, lastUpdateTime: string,
    offsetInfo?: OffsetInfo) {
    this.couponID = couponID
    this.couponName = couponName
    this.validityPeriodMode = validityPeriodMode
    this.startTime = startTime
    this.endTime = endTime
    this.status = status
    this.amountRule = amountRule
    this.distributionQuantity = distributionQuantity
    this.repeatedPickup = repeatedPickup
    this.categoryGroup = categoryGroup
    this.brandGroup = brandGroup
    this.catalogGroup = catalogGroup
    this.productGroup = productGroup
    this.recipientLimits = recipientLimits
    this.specifiedSubGroup = specifiedSubGroup
    this.specifiedPickupScenario = specifiedPickupScenario
    this.createdTime = createdTime
    this.lastUpdateTime = lastUpdateTime
    if (offsetInfo) {
      this.offsetInfo = offsetInfo
    }
  }
}

export interface CouponItem {
  // ID
  couponID: string
  // 名称
  couponName: string
  // 有效期模式: 0-固定时间 ; -1-领取后N天有效((暂时只支持固定时间)
  validityPeriodMode: string
  // 优惠开始时间
  startTime: string
  // 优惠结束时间
  endTime: string
  // 优惠券状态: 0-草稿 ; 1-评审 ; 2-生效(评审通过后生效,非商家取消状态不变) ; 3-失效(评审通过且生效后,商家在活动中途手动关闭) ; 4-取消(评审失败商家关闭)
  // 用户可见状态:所有生效优惠券(待使用+已使用+已过期) ; 失效前已使用的优惠券
  status: string
  // 使用规则
  amountRule: CouponRule
  // 发劵数量: -1-标识无限制 ; 其他数字标识发劵实际数量
  distributionQuantity: string
  // 支付重复领取：0-可以 ; 1-不可以
  repeatedPickup: string
  // 品类组
  categoryGroup: string
  // 品牌组
  brandGroup: string
  // 商品目录组
  catalogGroup: string
  // 商品组
  productGroup: string
  // 领取人限制: 0-所有人 ; 1-指定领取用户群 ; 2-指定领取场景(暂时只支持领取场景)
  recipientLimits: string
  // 领取用户群: 0-普通 ; 1-等级 ; 2-会员
  specifiedSubGroup: Array<KeyValue>
  // 领取场景: 0-新用户注册(暂时只支持新用户注册)
  specifiedPickupScenario: Array<KeyValue>
  // 创建时间
  createdTime: string
  // 最近更新时间
  lastUpdateTime: string
  // 核销单
  offsetInfo?: OffsetInfo
}

export interface CouponRule {
  // ID
  amountRuleNo: string
  // 描述说明
  amountRuleDesc: string
  // 优惠模式: 固定金额-0(暂时只支持固定金额)
  discountMode: string
  // 优惠类型：满减-0 ; 立减-1 ; 折扣-2
  discountType: string
  // 满减标准
  fullAmount: string
  // 立减额度
  discountAmount: string
  // 折扣系数
  discountCoefficient: string
}

export interface KeyValue {
  key: number
  value: string
}

export interface OffsetInfo {
  // 核销ID
  offsetID: string
  // 领取时间，默认核销时间
  couponCollectionTime: string
  // 核销时间
  couponOffsetTime: string
  // 核销订单
  offsetOrder: string
  // 核销状态：0-已核销(活动期间正常使用的优惠券) ; 1-已失效(活动期间商家手动关闭但用户已使用的优惠券)
  couponStatus: string
}

