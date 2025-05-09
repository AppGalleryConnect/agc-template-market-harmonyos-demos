export class HttpCode {
  static readonly SUCCESS = 0
  static readonly SUCCESS_200 = 200
  static readonly CANCEL_PAY = 1001930000
  static readonly PAY_FAILED = 1001930001
  static readonly NETWORK_ERROR = 1001930011
  static readonly DUPLICATE_REQUEST = 1001930010
}

export class RequestUrl {
  // base url
  static readonly BASE_URL = 'https://xxxxxxxxx/tea-drink-orders/v1/app';
  // 1、通过APPID调用接口获取店铺storeId，再通过接口获取店铺信息
  static readonly GET_HM_SYSTEM_URL = 'getHmSystem'
  // 2、通过静默登入获取用户openID unionID,然后通过接口获取用户信息
  static readonly GET_LOGIN_HM_URL = 'getUserInfo'
  // 关联手机号
  static readonly GET_OPEN_LOGIN_HM_URL = 'getOpenLoginHm'
  // 解除关联手机号
  static readonly GET_CLOSE_LOGIN_HM_URL = 'getCloseLoginHm'
  // 获取店铺列表
  static readonly GET_STORE_LIST_URL = 'getStoreList'
  static readonly GET_STORE_INFO_URL = 'getStoreInfo'
  // 获取商家优惠券信息
  static readonly GET_COUPONS_URL = 'getCoupons'
  // 5、通过storeId接口获取商品信息
  static readonly GET_DISHES_LIST_URL = 'getDishesList'
  // 6、扫码进入选品页清除此用户历史购物车记录
  // 清空购物车
  static readonly GET_DEL_CAR_URL = 'clearMyCar'
  // 8、餐饮后付提交订单
  static readonly GET_ADD_DN_ORDER_URL = 'addDnOrder'
  // 9、我的订单列表
  static readonly GET_MY_ORDER_URL = 'getMyOrder'
  // 10、取消订单
  static readonly GET_CANCEL_ORDER_URL = 'cancelOrder'
  // 订单详情
  static readonly GET_ORDER_INFO_URL = 'getOrderInfo'
  // 通过优惠券couponId、userId接口领取优惠券
  static readonly LQ_COUPONS_URL = 'lqCoupons'
  // 11、我的购物车
  static readonly GET_MY_CAR_URL = 'getMyCar'
  // 13、删除已经添加到购物车的饮品数量
  static readonly GET_UPD_CAR_URL = 'updateMyCar'
  // 14、点击选规格，获取商品规格信息并弹窗选择
  static readonly GET_GOOD_INFO_URL = 'getGoodInfo'
  // 获取单个商品规格信息
  static readonly GET_GOOD_SPEC_URL = 'getGoodSpec'
  // 16、规格饮品到购物车
  static readonly GET_ADD_CAR_URL = 'addCar'
  // 查询我的优惠券列表
  static readonly GET_MY_COUPONS_URL = 'getMyCoupons'
  // 删除订单
  static readonly GET_DELETE_ORDER_URL = 'deleteOrder'
  // 获取华为支付信息
  static readonly GET_HUAWEI_PAY_INFO_URL = 'getHuaweiPayInfo'
  // 修改用户信息
  static readonly MODIFY_USER_INFO = 'modifyUserInfo'
  // 获取用户收货地址
  static GET_USER_ADDRESS_LIST = 'getUserAddressList'
  // 新增修改用户收货地址
  static GET_USER_ADDRESS = 'getUserAddress'
  // 新增修改用户收货地址
  static MODIFY_USER_ADDRESS = 'modifyUserAddress'
  // 删除用户收货地址
  static DELETE_USER_ADDRESS = 'deleteUserAddress'
  // 获取隐私内容
  static GET_PRIVACY_INFO = 'getPrivacyInfo'
}

export class CommonUrl {
  static readonly CLOUD_STORAGE_URL = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/'
}

export class Constants {
  // 接口请求超时时间
  static readonly REQUEST_TIME_OUT = 3 * 1000
  static readonly FULL_SIZE = '100%'
  static readonly BORDER_WIDTH = 16
  // 用户授权成功
  static readonly USER_GRANT_SUCCESS = 0
  // 店铺休息
  static readonly STORE_REST = true
  // 优惠券
  static readonly COUPON = '1'
  // 优惠券类型 店内
  static readonly COUPON_TYPE_STORE = '2'
  // 优惠券类型 店内和外卖
  static readonly COUPON_TYPE_ALL = '3'
  // 优惠券领取状态 2 未领取
  static readonly COUPON_STATE_NOT_COLLECT = 2
  // 订单支付超时时间
  static readonly COUNTDOWN_TIME = 30
  // 时间转换
  static readonly SECOND_TO_MIN = 60
  // 延迟时间1000ms
  static readonly DELAY_TIME_1000 = 1000
  static readonly DRINK_PROCESS_MAX = 6
  static readonly STORE_MAKING_PROCESS_MAX = 15
  static readonly AM_PM = 12
  static readonly MAP_HEIGHT_DEFAULT = 216
  static readonly MID_DAY_TIME = '12:00'
  static readonly TELEPHONE_LENGTH = 11
  // 配送范围：10公里
  static readonly ADDRESS_OVER = 10000
}

export enum PayType {
  HUAWEI_PAY = 1,
}

// 订单列表tab
export enum OrderListEnum {
  // 全部
  ALL = 0,
  // 待支付
  TO_BE_PAID,
  // 已完成
  COMPLETED,
  // 已取消
  CANCELED,
}

// 订单状态
export enum OrderStateEnum {
  // 待支付
  TO_BE_PAID = 0,
  // 制作中
  MAKING,
  // 配送中
  DELIVERING,
  // 已完成
  COMPLETED,
  // 已取消
  CANCELED,
}

// 订单状态
export const orderStateMap: Record<number, ResourceStr> = {
  // 待支付
  0: $r('app.string.to_be_paid'),
  // 制作中
  1: $r('app.string.making'),
  // 配送中
  2: $r('app.string.delivering'),
  // 已完成
  3: $r('app.string.completed'),
  // 已取消
  4: $r('app.string.canceled'),
}

// 商品类别
export enum GoodSpecEnum {
  // 正常
  NORMAL = '1',
  // 选规格
  SPEC_TYPE = '2',
  // 选套餐
  PACKAGE_TYPE = '3',
}

// 订单类型
export enum OrderTypeEnum {
  // 到店自取
  PICK_SELF = 0,
  // 外卖配送
  TAKEAWAY_DELIVERY = 1,
}


// 订单类型
export const orderTypeMap: Record<number, ResourceStr> = {
  // 到店自取
  0: $r('app.string.pick_self_tag'),
  // 外卖配送
  1: $r('app.string.takeaway_tag'),
}

// 订单列表枚举
export enum OrderListTypeEnum {
  TODAY_LIST = 0,
  HISTORY_LIST,
}

// 订单列表枚举
export enum CouponStateEnum {
  NOT_PICKED_UP = 0,
  USABLE,
  USED,
}

// 订单列表枚举
export enum UserSexEnum {
  male = 1,
  female,
}

// 地址标签
export enum AddressTagEnum {
  DEFAULT = 1,
  HOME,
  COMPANY,
  SCHOOL,
}

// 地址标签
export const addressTagMap: Record<number, ResourceStr> = {
  // 常用
  1: $r('app.string.address_default'),
  // 家
  2: $r('app.string.address_home'),
  // 公司
  3: $r('app.string.address_company'),
  // 学校
  4: $r('app.string.address_school'),
}
