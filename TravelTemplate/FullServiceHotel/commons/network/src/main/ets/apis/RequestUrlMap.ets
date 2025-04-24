export enum RequestUrlMap {
  /**
   * 配置信息
   */
  COMMON_TENANT_INFO = '/common/tenantInfo',
  COMMON_TENANT_CONFIG = '/common/tenantConfig',
  COMMON_TRAFFIC_DETAIL = '/common/trafficDetail',
  COMMON_GRADE_LIST = '/common/gradeList',
  COMMON_PAGE_BANNER = '/common/pageBanner',
  /**
   * 用户信息
   */
  USER_LOGIN = '/user/login',
  USER_SEARCH = '/user/search',
  USER_UPDATE = '/user/update',
  /**
   * 公告
   */
  NOTICE_LIST = '/api/notice/list',
  NOTICE_DETAIL = '/api/notice/detail',
  /**
   * 评论
   */
  COMMON_SHOP_LIST = '/comment/shopList',
  COMMENT_LIST = '/comment/list',
  COMMENT_CREATE = '/comment/create',
  /**
   * 订单
   */
  ORDER_LIST = '/order/list',
  ORDER_DETAIL_HOTEL = '/order/detail/hotel',
  ORDER_DETAIL_MEAL = '/order/detail/meal',
  /**
   * 酒店预订
   */
  HOTEL_LIST = '/hotel/list',
  HOTEL_ROOM_LIST = '/hotel/roomList',
  HOTEL_ROOM_DETAIL = '/hotel/roomDetail',
  /**
   * 餐饮预订
   */
  RESTAURANT_LIST = '/restaurant/list',
  RESTAURANT_DETAIL = '/restaurant/detail',
  RESTAURANT_MEAL_DETAIL = '/restaurant/mealDetail',
  /**
   * 宴会厅预定
   */
  BANQUET_HOTEL_LIST = '/banquet/hotelList',
  BANQUET_LIST = '/banquet/list',
  BANQUET_DETAIL = '/banquet/detail',
  /**
   * 支付
   */
  PREPAY_HOTEL = '/prepay/hotel',
  PREPAY_MEAL = '/prepay/meal',
}
