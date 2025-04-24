export class HttpCode {
  static readonly SUCCESS = 1
  static readonly STATUE_ERROR = 2
  static readonly SUCCESS_STR = '1'
  static readonly SUCCESS_200 = 200
  static readonly CANCEL_PAY = 1001930000
  static readonly PAY_FAILED = 1001930001
  static readonly NETWORK_ERROR = 1001930011
  static readonly DUPLICATE_REQUEST = 1001930010
}

export class RequestUrl {
  // base url
  static readonly BASE_URL = 'https://xxxxxxxxx/catering/v1/app';
  // 1、通过APPID调用接口获取店铺storeId，再通过接口获取店铺信息
  static readonly GET_HM_SYSTEM_URL = 'getHmSystem'
  // 2、通过静默登入获取用户openID unionID,然后通过接口获取用户信息
  static readonly GET_LOGIN_HM_URL = 'getUserInfo'
  // 关联手机号
  static readonly GET_OPEN_LOGIN_HM_URL = 'getOpenLoginHm'
  // 解除关联手机号
  static readonly GET_CLOSE_LOGIN_HM_URL = 'getCloseLoginHm'
  // 3、通过storeId接口获取店铺信息
  static readonly GET_STORE_INFO_URL = 'getStoreInfo'
  // 3、如果没有tableId，通过storeId接口获取全部桌位信息
  static readonly GET_TABLE_TITLE_URL = 'getTableTitle'
  // 4、通过桌号id接口获取桌位信息
  static readonly GET_ZHUO_HAO_URL = 'getTableInfo'
  // 5、通过storeId接口获取商品信息
  static readonly GET_DISHES_LIST_URL = 'getDishesList'
  // 6、扫码进入选品页清除此用户历史购物车记录
  // 清空购物车
  static readonly GET_DEL_CAR_URL = 'clearMyCar'
  // 7、通过storeId 、userId接口获取商家优惠券信息
  static readonly GET_COUPONS_URL = 'getCoupons'
  // 8、餐饮后付提交订单
  static readonly GET_ADD_DN_ORDER_URL = 'addDnOrder'
  // 9、我的订单列表
  static readonly GET_MY_ORDER_URL = 'getMyOrder'
  // 10、取消订单
  static readonly GET_CANCEL_ORDER_URL = 'cancelOrder'
  // 订单详情
  static readonly GET_ORDER_INFO_URL = 'getOrderInfo'
  // 通过优惠券couponId、userId接口领取优惠券
  static readonly GET_LQ_COUPONS_URL = 'lqCoupons'
  // 11、我的购物车
  static readonly GET_MY_CAR_URL = 'getMyCar'
  // 13、删除已经添加到购物车的菜品数量
  static readonly GET_UPD_CAR_URL = 'updateMyCar'
  // 14、点击选规格，获取商品规格信息并弹窗选择
  static readonly GET_GOOD_INFO_URL = 'getGoodInfo'
  // 获取单个商品规格信息
  static readonly GET_GOOD_SPEC_URL = 'getGoodSpec'
  // 16、规格菜品到购物车
  static readonly GET_ADD_CAR_URL = 'addCar'
  // 查询我的优惠券列表
  static readonly GET_MY_COUPONS_URL = 'getMyCoupons'
  // 查询帮助信息
  static readonly GET_HELP_URL = 'getHelpMsg'
  // 加菜
  static readonly GET_ADD_GOODS_URL = 'addGoods'
  // 删除订单
  static readonly GET_DELETE_ORDER_URL = 'deleteOrder'
  // 判断用户是否为新用户
  static readonly GET_IS_NEW_URL = 'getIsNew'
  // 获取华为支付信息
  static readonly GET_HUAWEI_PAY_INFO_URL = 'getHuaweiPayInfo'
}

export class Constants {
  // 接口请求超时时间
  static readonly REQUEST_TIME_OUT = 3 * 1000
  static readonly FULL_SIZE = '100%'
  // 用户授权成功
  static readonly USER_GRANT_SUCCESS = 0
  // 必选品
  static readonly GOODS_MUST = '1'
  // 店铺休息
  static readonly STORE_REST = '1'
  // 优惠券
  static readonly COUPON = '1'
  // 优惠券类型 店内
  static readonly COUPON_TYPE_STORE = '2'
  // 优惠券类型 店内和外卖
  static readonly COUPON_TYPE_ALL = '3'
  // 优惠券领取状态 2 未领取
  static readonly COUPON_STATE_NOT_COLLECT = 2
  // 页面边距
  static readonly BORDER_WIDTH = 16
  static readonly GOOD_TYPE_HOT = '1'
}

export class CommonUrl {
  static readonly CLOUD_STORAGE_URL = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/'
}

export enum StoreType {
  SCAN_TYPE = 1,
  PICK_NUM_TYPE
}

export enum PayType {
  HUAWEI_PAY = 1,
}

// 订单状态
export enum DnState {
  // 全部
  ALL = '1,2,3',
  // 待支付
  TO_BE_PAID = '1',
  // 已完成
  COMPLETED = '2',
  // 已取消
  CANCELED = '3',
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
  // 堂食
  STORE_DINING = 0,
  // 外带
  PICKING = 4,
}

// 订单详情行枚举
export enum OrderDetailRowEnum {
  XYH_MONEY = 0,
  MJ_MONEY,
  YHQ_MONEY,
  BOX_MONEY,
  PAY_TYPE,
  REAL_PAY,
  ORDER_TIME,
  ORDER_ID,
  TABLE_INFO,
  ORDER_TYPE,
  TABLEWARE,
  REMARK,
}

// 订单详情行枚举
export enum CouponStateEnum {
  USABLE = '0',
  USED = '1',
}

// 订单状态
export enum OrderStateEnum {
  All = 0,
  noFinished,
  finished,
  AfterSales
}