export enum RouterMap {
  MAIN_ENTRY = 'MainEntry',

  /** member */
  USER_LOGIN = 'BindPhonePage',
  USER_MEMBER_SUBSCRIPTION = 'MemberSubscriptionPage',

  /** order */
  ORDER_SUBMIT = 'OrderSubmitPage',
  ORDER_SEARCH = 'OrderSearchPage',
  ORDER_LIST = 'OrderListPage',
  ORDER_INFO = 'OrderInfoPage',
  ORDER_EXPRESS_INFO = 'OrderExpressInfoPage',
  ORDER_UPDATE_ADDRESS = 'UpdateAddressSheet',
  ORDER_REVIEW_CREATE = 'OrderReviewCreatePage',
  ORDER_REVIEW_INFO = 'OrderReviewInfoPage',

  /** points */
  POINTS_MALL = 'PointsMallPage',
  POINTS_EXPRESS_INFO = 'OrderExpressInfoPage',
  POINTS_RECORD = 'PointsRecordPage',
  POINTS_REDEMPTION_SUBMIT = 'RedemptionSubmitPage',
  POINTS_REDEMPTION_LIST = 'RedemptionListPage',
  POINTS_REDEMPTION_INFO = 'RedemptionInfoPage',

  /** product */
  PRODUCT_SWIPER = 'ProductSwiperPage',
  PRODUCT_INFO = 'ProductInfoPage',
  PRODUCT_REVIEW = 'ProductReviewPage',

  /** setting */
  SETTING = 'SettingPage',
  SETTING_PRIVACY = 'SettingPrivacyPage',
  SETTING_AGREEMENT = 'AgreementPage',
  USER_PROFILE_EDIT = 'EditProfilePage',
  USER_COUPON_PAGE = 'CouponPage',
  USER_COLLECTION = 'MyCollectionPage',
  USER_VIEW_HISTORY = 'ViewHistoryPage',

  /** shopping */
  USER_CUSTOM_SERVICE = 'CustomServicePage',
  PRODUCT_SEARCH = 'ProductSearchPage',
  PRODUCT_SEARCH_RESULTS = 'ProductSearchResultsPage',
  PRODUCT_SUBCATEGORY = 'SubCategoryPage',
  PRODUCT_SECKILL = 'SeckillListPage',

  /** others */
  PRODUCT_CATEGORY = 'CategoryPage',
  PRODUCT_CART = 'CartPage',
  UPDATE_ADDRESS = 'UpdateAddressPage',
}

export const SHARE_PAGE_MAP: string[] = [
  RouterMap.PRODUCT_INFO,
];

export const HSP_ROUTER_MAP: Map<RouterMap, string> = new Map([
  [RouterMap.USER_LOGIN, 'member'],
  [RouterMap.USER_MEMBER_SUBSCRIPTION, 'member'],
  [RouterMap.ORDER_SUBMIT, 'order'],
  [RouterMap.ORDER_SEARCH, 'order'],
  [RouterMap.ORDER_LIST, 'order'],
  [RouterMap.ORDER_INFO, 'order'],
  [RouterMap.ORDER_EXPRESS_INFO, 'order'],
  [RouterMap.POINTS_EXPRESS_INFO, 'order'],
  [RouterMap.ORDER_UPDATE_ADDRESS, 'order'],
  [RouterMap.ORDER_REVIEW_CREATE, 'order'],
  [RouterMap.ORDER_REVIEW_INFO, 'order'],
  [RouterMap.POINTS_MALL, 'points'],
  [RouterMap.POINTS_RECORD, 'points'],
  [RouterMap.POINTS_REDEMPTION_SUBMIT, 'points'],
  [RouterMap.POINTS_REDEMPTION_LIST, 'points'],
  [RouterMap.POINTS_REDEMPTION_INFO, 'points'],
  [RouterMap.PRODUCT_SWIPER, 'product'],
  [RouterMap.PRODUCT_INFO, 'product'],
  [RouterMap.PRODUCT_REVIEW, 'product'],
  [RouterMap.SETTING, 'setting'],
  [RouterMap.SETTING_PRIVACY, 'setting'],
  [RouterMap.SETTING_AGREEMENT, 'setting'],
  [RouterMap.USER_PROFILE_EDIT, 'setting'],
  [RouterMap.USER_COUPON_PAGE, 'setting'],
  [RouterMap.USER_COLLECTION, 'setting'],
  [RouterMap.USER_VIEW_HISTORY, 'setting'],
  [RouterMap.USER_CUSTOM_SERVICE, 'shopping'],
  [RouterMap.PRODUCT_SEARCH, 'shopping'],
  [RouterMap.PRODUCT_SEARCH_RESULTS, 'shopping'],
  [RouterMap.PRODUCT_SUBCATEGORY, 'shopping'],
  [RouterMap.PRODUCT_SECKILL, 'shopping'],
])