export enum RequestUrlMap {
  /**
   * 初始化配置
   */
  COMMON_HOME_CONFIG = 'common/home/config',
  COMMON_CATEGORY_PRODUCT = 'common/category/product',
  /**
   * 商品
   */
  PRODUCT_LIST = 'product/list',
  PRODUCT_DETAIL = 'product/detail',
  PRODUCT_STOCK = 'product/stock',
  PRODUCT_REVIEW = 'product/review',
  PRODUCT_COLLECT = 'product/collect',
  PRODUCT_COLLECT_STATUS = 'product/collect/status',
  PRODUCT_COLLECTED_LIST = 'product/collect/list',
  PRODUCT_VIEW_HISTORY = 'product/view-history',
  PRODUCT_VIEW_HISTORY_LIST = 'product/view-history/list',
  /**
   * 秒杀
   */
  SECKILL_SESSIONS = '/seckill/sessions',
  SECKILL_PRODUCT_LIST = '/seckill/product-list',
  SECKILL_PRODUCT_INFO = '/seckill/product-info',
  SECKILL_PRODUCT_ORDER_STATUS = '/seckill/product-info/order-status',
  SECKILL_RESERVE = '/seckill/reserve',
  SECKILL_RESERVE_STATUS = '/seckill/reserve-status',
  SECKILL_BATCH_RESERVE_STATUS = '/seckill/batch-reserve-status',
  SECKILL_CALENDAR = '/seckill/calendar',
  /**
   * 购物车
   */
  CART_INFO = 'cart/info',
  CART_LIST = 'cart/list',
  CART_PRODUCT = 'cart/product',
  CART_PRICE = 'cart/price',
  /**
   * 订单
   */
  ORDER_PRE_INFO = 'order/pre-info',
  ORDER_DEFAULT_PICKUP = 'order/default-pickup',
  ORDER_LIST = 'order/list',
  ORDER_DETAIL = 'order/detail',
  ORDER_UPDATE = 'order/detail',
  ORDER_DELETE = 'order/detail',
  ORDER_CREATE = 'order/detail',
  ORDER_EXPRESS = 'order/express',
  ORDER_ADD_COMMENT = 'order/comment',
  ORDER_PREPAY = 'order/prepay',
  /**
   * 用户相关
   */
  USER_LOGIN = 'user/login',
  USER_LOGOUT = 'user/logout',
  USER_INFO = 'user/info',
  USER_POINTS = 'user/points',
  USER_POINTS_DETAIL = 'user/points-detail',
  USER_POINTS_PRODUCT = 'user/points/product-list',
  USER_POINTS_REDEMPTION = 'user/points/product-redemption',
  USER_MEMBERSHIP = 'user/membership',
  /**
   * 优惠券
   */
  COUPON_LIST = 'coupon/list',
  COUPON_CLAIM = 'coupon/claim',
  COUPON_UPDATE = 'coupon/update',
  /**
   * 兑换记录
   */
  USER_REDEMPTION_LIST = 'user/redemption/list',
  USER_REDEMPTION_DETAIL = 'user/redemption/detail',
  USER_REDEMPTION_ADDRESS = 'user/redemption/address',
  USER_REDEMPTION_URGE = 'user/redemption/urge',
  USER_REDEMPTION_CONFIRM = 'user/redemption/confirm',
  USER_REDEMPTION_DELETE = 'user/redemption/delete',
}