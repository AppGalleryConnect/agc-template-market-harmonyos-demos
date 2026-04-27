export enum RouterMap {
  // 首开申请用户许可
  SAFE_PAGE = 'SafePage',
  // 主入口
  MAIN_ENTRY = 'MainEntry',
  // 广告页
  SPLASH_PAGE = 'SplashPage',
  // 签到福利页
  VIP_BENEFIT_PAGE = 'VipBenefitPage',

  // 查询快递页
  ORDER_PAGE = 'OrderPage',
  // 快递下单成功后，待取件和待入柜详情页
  ORDER_DETAIL = 'OrderDetailPage',
  // 编辑快递订单页
  EDIT_ORDER_PAGE = 'EditOrderPage',
  // 已揽件之后的状态的页面
  ORDER_INFO_PAGE = 'OrderInfoPage',

  // 寄快递
  EXPRESS_PAGE = 'ExpressPage',
  GOODS_PAGE = 'GoodsPage',
  TEMPLATE_PAGE = 'TemplatePage',
  TEMPLATE_LIST_PAGE = 'TemplateListPage',
  SERVICE_POINT_PAGE = 'ServicePointPage',

  // 积分明细
  POINTS_HISTORY_PAGE = 'PointsHistoryPage',
  // 会员页
  PURCHASE_PAGE = 'PurchasePage',
  // 登录页
  QUICK_LOGIN_PAGE = 'QuickLoginPage',
  // 个人信息页
  PERSONAL_INFO_PAGE = 'PersonalInformationPage',
  // 我的优惠券页
  COUPON_PAGE = 'CouponPage',
  // 设置页
  SETTING_PAGE = 'SettingPage',

  // 隐私设置
  SETTING_PRIVACY = 'SettingPrivacyPage',
  PRIVACY_PAGE = 'PrivacyPage',
  REAL_NAME_AUTH_PAGE = 'RealNameAuthPage',
  ADDRESS_MANAGE_PAGE = 'AddressManagePage',
  ADDRESS_EDIT_PAGE = 'AddressEditPage',
}

// 寄件方式
export enum ShippingMethod {
  SELF_DELIVERY = 1,
  CONTACT_COURIER = 2,
  DAILY_PICKUP = 3,
}

// 支付方式
export enum PayMethod {
  PREPAID = 1,
  CASH_DELIVERY = 2,
}

// 运单状态
export enum ParcelStatus {
  // 待取件
  AWAITING_PICKUP = 0,
  // 待入柜
  PENDING_LOCKER = 1,
  // 已取件
  COLLECTED = 2,
  // 运送中
  IN_TRANSIT = 3,
  // 派送中
  DELIVERY = 4,
  // 待签收
  OUT_FOR_DELIVERY = 5,
  // 已签收
  DELIVERED = 6,
  // 已取消
  CANCELED = 7,
}

// 支付状态
export enum PayStatus {
  PENDING = 0,
  PAID = 1
}

// 页面的加载状态
export enum PageStatus {
  IDLE = 'idle',
  LOADING = 'loading',
  SUCCESS = 'success',
  EMPTY = 'empty'
}

export enum ShippingType {
  // 上门取件
  PICKUP_SERVICE = 1,
  // 服务点自寄
  SERVICE_POINT = 2,
}

export interface ITime {
  text: string,
  value: number,
  timeList: string[]
}