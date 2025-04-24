export enum AppStorageMap {
  // 租户ID
  TENANT_ID = 'tenantId',
  // 预加载缓存首页结构
  STRUCTURE_CACHE = 'structureCache',
  // 用户信息
  USER_INFO = 'userInfo',
}

export enum RouterMap {
  // 公告
  HOME_PUBLIC_NOTICE = 'PublicNotice',

  // 酒店列表
  HOTEL_LIST = 'HotelListPage',
  // 房间列表
  HOTEL_ROOM_LIST = 'RoomListPage',
  // 房间详情页
  HOTEL_ROOM_DETAIL = 'RoomInfoPage',
  // 房间预下单页
  HOTEL_ROOM_ORDER = 'HotelOrderPage',

  // 餐厅列表
  RESTAURANT_LIST = 'RestaurantListPage',
  // 餐厅信息
  RESTAURANT_INFO = 'RestaurantPage',
  // 套餐详情
  RESTAURANT_FOOD_INFO = 'FoodInfoPage',
  // 套餐预下单页
  RESTAURANT_FOOD_ORDER = 'FoodOrderSubmitPage',

  // 宴会厅酒店列表
  BANQUET_HOTEL_LIST = 'BanquetHotelListPage',
  // 宴会厅房间列表
  BANQUET_LIST = 'BanquetListPage',
  // 宴会厅房间详情
  BANQUET_INFO = 'BanquetInfoPage',

  // 订单列表
  ORDER_LIST = 'MyOrders',
  // 订单详情
  ORDER_DETAIL = 'OrderDetail',

  // 位置信息
  COMMON_LOCATION = 'Location',
  // 酒店介绍
  COMMON_INTRODUCTION = 'Introduction',
  //二维码展示页
  COMMON_QR_CODE = 'QRCodePage',

  // 评价列表
  COMMENT_LIST = 'Comments',
  // 提交评价
  COMMENT_SUBMISSION = 'SubmitComment',

  // 我的-修改个人信息
  MINE_PROFILE_EDIT = 'ProfileEditPage',
  // 我的-隐私政策
  MINE_PRIVACY_POLICY = 'PrivacyPolicyPage',
}
