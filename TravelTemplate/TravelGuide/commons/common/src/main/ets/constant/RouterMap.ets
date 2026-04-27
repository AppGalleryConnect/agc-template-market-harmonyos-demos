/**
 * 页面路由注册
 */
export class RouterMap {
  // app隐私
  public static readonly PRIVACY_AGREEMENT_PAGE = 'PrivacyAgreementPage'
  // 协议内容页
  public static readonly PROTOCOL_WEB_VIEW_NAME = 'ProtocolWebView'
  // 首页
  public static readonly MAIN_PAGE = 'MainPage'
  // 登录页面
  public static readonly LOGIN_PAGE = 'LoginPage'
  //测试页面
  public static readonly DEMO_PAGE = 'DemoPage'
  public static readonly CITY_SELECT_PAGE = 'CitySelectPage'
  public static readonly OVERSEAS_CITY_SELECT_PAGE = 'OverseasCitySelectPage'
  public static readonly CITY_SELECT_RETURN_PAGE = 'CitySelectReturnPage'
  public static readonly TICKET_SELECT_CITY_BACK_PAGE = 'TicketSelectCityBackPage'
  // 火车票查询
  public static readonly TICKET_PRICES_PAGE = 'TicketPricesPage'
  // 飞机票详情
  public static readonly TICKET_DETAIL_PAGE = 'TicketDetailPage'
  // 飞机票订单确认
  public static readonly TICKET_ORDER_PAGE = 'TicketOrderPage'
  // 火车票票订单确认
  public static readonly PLANE_ORDER_PAGE = 'PlaneOrderPage'
  // 汽车票订单确认
  public static readonly CAR_ORDER_PAGE = 'CarOrderPage'
  // 火车票详情
  public static readonly PLANE_DETAIL_PAGE = 'PlaneDetailPage'
  //汽车票详情
  public static readonly CAR_DETAIL_PAGE = 'CarDetailPage'
  //飞机票订单详情及取消订单
  public static readonly TICKET_PENDING_PAYMENT_PAGE = 'TicketPendingPaymentPage'
  //火车票订单详情及取消订单
  public static readonly PLANE_PENDING_PAYMENT_PAGE = 'PlanePendingPaymentPage'
  //汽车票订单详情及取消订单
  public static readonly CAR_PENDING_PAYMENT_PAGE = 'CarPendingPaymentPage'
  // 出行人
  public static readonly TRAVE_LER_PAGE = 'TravelerPage'
  // 编辑出行人
  public static readonly TEDIT_RAVE_LER_PAGE = 'EditTravelerPage'
  // 消息通知页面名称
  public static readonly MESSAGE_CENTER_PAGE = 'MessageCenterPage'
  // 系统消息
  public static readonly SYS_MESSAGE_PAGE = 'SystemMessagePage'
  // 意见反馈
  public static readonly FEEDBACK_PAGE = 'FeedbackPage'
  // 意见反馈历史
  public static readonly FEEDBACK_HISTORY_PAGE = 'FeedbackHistoryPage'
  // 个人信息页
  public static readonly PERSONAL_CENTER_PAGE = 'EditPersonalCenter'
  // 隐私设置
  public static readonly PRIVACY_SETTINGS_PAGE = 'PrivacySettingsPage'
  // 关于
  public static readonly ABOUT_PAGE = 'AboutPage'
  // 使用协议弹框
  public static readonly PRIVACY_USE_PAGE = 'PrivacyUseAlertPage'
  // 三方信息共享清单
  public static readonly PRIVACY_3RD_PARTY_SHARE_PAGE = 'Privacy3rdPartySharePage'
  // 个人信息收集清单
  public static readonly PRIVACY_INFO_COLLECT_PAGE = 'PrivacyInfoCollectPage'
  // 设置页面
  public static readonly SET_UP_PAGE = 'SetUpPage'
  // 搜索框
  public static readonly SEARCH_PAGE = 'SearchPage'
  // 酒店
  public static readonly HOTEL_PAGE = 'HotelPage'
  // 机票
  public static readonly PLANE_TICKET_PAGE = 'PlaneTicketPage'
  // 酒店搜索
  public static readonly SEARCH_HOTEL_PAGE = 'SearchHotelPage'
  // 酒店列表
  public static readonly HOTEL_LIST_PAGE = 'HotelListPage'
  // 订单管理
  public static readonly ORDER_MANAGEMENT_PAGE = 'OrderManagementPage'
  // 收到的赞
  public static readonly MY_LIKES_PAGE = 'MyLikesPage'
  // 我的帖子
  public static readonly MY_POST_PAGE = 'MyPostPage'
  // 常用信息
  public static readonly COMMON_INFO_PAGE = 'CommonInfoPage'
  // 常用信息新增
  public static readonly COMMON_INFO_ADD_PAGE = 'CommonInfoAddPage'
  // 常用发票新增
  public static readonly INVOICE_ADD_PAGE = 'InvoiceAddPage'
  // 发布帖子
  public static readonly PUBLISH_POST_PAGE = 'PublishPostPage'
  // 旅游
  public static readonly TOUR_PAGE = 'TourPage'
  // 旅游列表
  public static readonly TOUR_LIST_PAGE = 'TourListPage'
  // 旅游详情
  public static readonly TOUR_DETAIL_PAGE = 'TourDetailPage'
  // 旅游购买须知
  public static readonly PURCHASE_NOTES_PAGE = 'PurchaseNotesPage'
  // 旅游订单页
  public static readonly TOUR_ORDER_PAGE = 'TourOrderPage'
  // 旅游订单详情页
  public static readonly TOUR_ORDER_DETAIL_PAGE = 'TourOrderDetailPage'
  // 景点/攻略
  public static readonly ATTRACTION_PAGE = 'AttractionPage'
  // 旅游热点
  public static readonly TRAVEL_HOTSPOT_PAGE = 'TravelHotspotPage'
  // 口碑榜
  public static readonly REPUTATION_PAGE = 'ReputationPage'
  // 酒店详情
  public static readonly HOTEL_DETAILS_PAGE = 'HotelDetailsPage'
  // 景点详情页
  public static readonly ATTRACTION_DETAIL_PAGE = 'AttractionDetailPage'
  // 亮点设施
  public static readonly HOTEL_FACILITY_PAGE = 'HotelFacilityPage'
  // 提交订单
  public static readonly SUBMIT_ORDER_PAGE = 'SubmitOrderPage'
  // 旅行足迹页
  public static readonly JOURNEY_FOOTPRINT_PAGE = 'JourneyFootprintPage'
  // 帖子详情页
  public static readonly POST_DETAIL_PAGE = 'PostDetailPage'
  // 评论页面
  public static readonly COMMENT_PAGE = 'CommentPage'
  // 订单详情
  public static readonly HOTEL_ORDER_DETAIL_PAGE = 'HotelOrderDetailPage'
  // 报销凭证
  public static readonly REIMBURSEMENT_VOUCHER_PAGE = 'ReimbursementVoucherPageBuilder'
  // 我的收藏
  public static readonly MY_COLLECT_PAGE = 'MyCollectPage'
  // 实名认证
  public static readonly REAL_NAME_AUTH_PAGE = 'RealNameAuthPage'
  // 地图页面
  public static readonly MAP_PAGE = 'MapPage'
  // 景点地图页面
  public static readonly ATTRACTION_MAP_PAGE = 'AttractionMapPage'
  // 城市指南页
  public static readonly CITY_GUIDE_PAGE = 'CityGuidePage'
  // 路线规划页
  public static readonly ROUTE_PLANNING_PAGE = 'RoutePlanningPage'
  //订单出行人列表页面
  public static readonly TRAVEL_PEOPLE_LIST_PAGE = 'TravelPeopleListPage'
  //订单新增、编辑出行人页面
  public static readonly TRAVEL_PEOPLE_ADD_PAGE = 'TravelPeopleAddPage'
  //常用人信息
  public static readonly COMMON_PEOPLE_ADD_PAGE = 'CommonPeopleAddPageBuilder'
}

