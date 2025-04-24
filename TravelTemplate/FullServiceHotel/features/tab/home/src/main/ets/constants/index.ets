export enum ServiceType {
  PUBLIC_NOTICE = 'PublicNotice', // 公告
  HOTEL_ROOM = 'HotelListPage', // 酒店预订
  CATERING = 'RestaurantListPage', // 餐饮预订
  BALLROOM = 'BanquetHotelListPage', // 宴会厅预订
  ORDERS = 'MyOrders', // 我的订单
  CONTACT_US = 'ContactUs', // 联系我们
  COMMENTS = 'Comments', // 客人说
  LOCATION = 'Location', // 酒店位置
  INTRODUCTION = 'Introduction', // 酒店介绍
}

export enum ServiceLink {
  HOTEL_ROOM = 'orderoom', // 酒店预订
  CATERING = 'orderfood', // 餐饮预订
  BALLROOM = 'shop', // 宴会厅预订
  ORDERS = 'myorder', // 我的订单
  CONTACT_US = 'phone', // 联系我们
  COMMENTS = 'comment', // 客人说
  LOCATION = 'traffic', // 酒店位置
  INTRODUCTION = 'hotel', // 酒店介绍
}

export enum TemplateStructureType {
  // 轮播图
  CAROUSEL = 1,
  // 二图模块
  PICS_2 = 2,
  // 三图模块
  PICS_3 = 3,
  // 小图标模块
  ICONS = 4,
  // 商城一图
  MALL_PIC = 5,
  // 商城列表
  MALL_LIST = 6,
}
