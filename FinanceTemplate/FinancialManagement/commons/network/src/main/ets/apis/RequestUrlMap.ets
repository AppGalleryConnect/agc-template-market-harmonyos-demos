export enum RequestUrlMap {
  /**
   * 用户信息
   */
  USER_LOGIN = '/user/login',
  USER_LOGOUT = '/user/logout',
  USER_SEARCH = '/user/search',
  USER_UPDATE = '/user/update',
  USER_ACCOUNT = '/user/account',
  /**
   * 配置
   */
  Sale_Type_List = '/sale/type/list',
  MINIMUM_PURCHASE_AMOUNT_LIST = '/minimum/purchase/amount/list',
  RISK_LEVEL_LIST = '/risk/level/list',
  CYCLE_LIST = '/cycle/list',
  ARRANGEMENT_LIST = '/arrangement/list',
  TRANSACTION_TYPE_LIST = '/transaction/type/list',
  TRANSACTION_DATE_LIST = '/transaction/date/list',
  /**
   * 产品
   */
  BANNER_LIST = '/banner/list',
  PRODUCT_TYPE_LIST = '/product/type/list',
  PRODUCT_LIST = '/product/list',
  PRODUCT_INFO = '/product/info',
  PRODUCT_BUY_RULE = '/product/buy/rule',
  PRODUCT_REDEMPTION_RULE = '/product/redemption/rule',
  PRODUCT_PURCHASE_PROCESS = '/product/purchase/process',
  PRODUCT_REDEMPTION_PROCESS = '/product/redemption/process',
  PRODUCT_HISTORICAL_PERFORMANCE_LIST = '/product/historical/performance/list',
  PRODUCT_PROFILE = '/product/profile',
  ANNUALIZED_DATASET = '/annualized/dataset',
  REVENUE_DATASET = '/revenue/dataset',
  ADD_PRODUCT_TO_CART = '/add/product/to/cart',
  DELETE_PRODUCT_FROM_CART = '/delete/product/from/cart',
  GET_PRODUCT_FROM_CART = '/get/product/from/cart',
  NOTICE_LIST = '/notice/list',
  PREPAY = '/prepay',

  /**
   * 持仓
   */
  POSITION_LIST = '/position/list',
  POSITION_INFO = '/position/info',
  POSITION_REDEMPTION = '/position/redemption',
  SUBMIT_POSITION_REDEMPTION = '/submit/position/redemption',
  TRANSACTION_RECORD_LIST = '/transaction/record/list',
  MONTH_TRANSACTION_RECORD_LIST = '/month/transaction/record/list',
  TRANSACTION_RECORD_INFO = '/transaction/record/info',
  MY_REGULAR_CHOICE_LIST = '/my/regular/choice/list',
  REVENUE_INFO = '/revenue/info',
  REGULAR_INVESTMENT_LIST = '/regular/investment/list',
  INVESTMENT_RECORD_LIST = '/investment/record/list',
  REGULAR_INVESTMENT_INFO = '/regular/investment/info',
  SEND_VERIFICATION_CODE = '/send/verification/code',
  SUBMIT_VERIFICATION_CODE = '/submit/verification/code',
  SUBMIT_DOLLAR_COST_AVERAGING = '/submit/dollar/cost/averaging',
  POSITION_RECORD = '/position/record'
}
