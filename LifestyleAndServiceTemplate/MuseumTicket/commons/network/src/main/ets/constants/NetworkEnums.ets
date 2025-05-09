export enum RequestUrl {
  USER_BIND_PHONE = '/api/user/bindPhone',
  USER_CANCEL_PHONE='/api/user/cancelPhone',
  USER_GET_INFO = '/api/user/getInfo',
  USER_LOGIN='/api/user/login',
  HOME_RECOMMEND_LIST='/api/home/getRecommendList',
  ORDER_LIST_INFO='/api/order/getListInfo',
  ORDER_TICKET_DETAIL='/api/order/getTicketDetail',
  PERFORMANCE_INFO='/api/performance/getInfo',
//  免费约展时间信息
  ORDER_DAY_TICKET='/api/order/getDayTicket',
//   讲解服务
  EXPLAIN_TEXT='/api/home/getExplainText',
//   省博介绍
  INTRODUCE_TEXT='/api/home/getIntroduceText',
//   停车缴费
  PARKING_TEXT='/api/home/getParkingText',
//   隐私政策
  PRIVACY_TEXT='/api/mine/getPrivacyText',
//   获取常用联系人
  CONTACTS_INFO='/api/contacts/getInfo',
//  更新常用联系人
  UPDATE_CONTACT='/api/contacts/update',
//  取消订单
  CANCEL_ORDER='/api/order/cancel',
//  免费约展
  ORDER_FREE='/api/order/free',
//  付费约展时间信息
  BUY_TIME_TICKET='/api/order/getTimeTicket',
//   票种信息
  TICKET_TYPE_INFO='/api/ticket/getTypeInfo',
//   付费约展预支付
  BUY_TICKET='/api/ticket/prepay',
//   更新用户信息
  UPDATE_USERINFO='/api/user/update',
//   获取顶部banner图片资源
  BANNER_IMG='/api/img/getBanner',
//   删除常用参观人
  DEL_VISITOR='/api/contacts/del',
//   交通信息
  TRAFFIC_DETAIL='/api/traffic/detail'
}



