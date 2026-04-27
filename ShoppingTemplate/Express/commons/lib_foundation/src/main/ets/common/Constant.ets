/**
 * 跳转main页面的参数
 */
export interface IJumpCategoryParam {
  tabIndex: number;
  listInitialIndex: number;
}

/*
:todo 网络请求base url，真实网络请求可以替换请求地址
*/
export enum CurAppInfo {
  BASE_URL = '', // 服务端请求基础url
}

/**
 * AppStorage应用临时缓存映射表
 */
export enum AppStorageMap {
  TOKEN = 'Token',
  UI_CONTEXT = 'uiContext',
}


/**
 * 订单类别
 */
export enum OrderType {
  ALL = '全部',
  SEND = '寄快递',
  RECEIVE = '收快递',
}

/**
 * 订单状态
 */
export enum OrderStatus {
  ALL = '全部',
  SUCCESS = '成功',
  FAIL = '失败',
  DO_ING = '进行中'
}

/**
 * 快递状态
 */
export enum ExpressStatus {
  ALL = '全部',
  PICKUP_PENDING = '待取件',
  PICKUP_ENDING = '已揽件',
  IN_TRANSIT = '运送中',
  IN_DELIVERY = '派送中',
  SIGNED_FOR = '已签收',
  CANCEL = '已取消',
}

/**
 * 快递取件方式
 */
export enum ShippingMethod {
  PICK_UP_AT_HOME = '上门取件',
  SELF_SENDING = '自寄',
}

/**
 * 支付方式
 */
export enum PaymentMethod {
  PAY_NOW = '现付',
  PAY_ON_DELIVERY = '到付',
}

/**
 * 常量类
 */
export class CommonConstants {
  // Font weight
  static readonly DIALOG_TITLE_FONT_WEIGHT: number = 700;
  static readonly DIALOG_BUTTON_FONT_WEIGHT: number = 500;
  static readonly NORMAL_FONT_WEIGHT: number = 400;
  // Opacity
  static readonly FIRST_LEVEL_OPACITY: number = 0.9;
  static readonly SECOND_LEVEL_OPACITY: number = 0.6;
  static readonly HALF_OPACITY: number = 0.5;
  static readonly THIRD_LEVEL_OPACITY: number = 0.3;
  // Blur
  static readonly REGULAR_BLUR: number = 250;
  // Space
  static readonly SPACE_4: number = 4;
  static readonly SPACE_8: number = 8;
  static readonly SPACE_12: number = 12;
  static readonly SPACE_16: number = 16;
  // MaxLines
  static readonly MAX_LINE_TWO: number = 2;
  // Column count
  static readonly SM_COLUMN_COUNT: number = 1;
  static readonly MD_COLUMN_COUNT: number = 2;
  static readonly LG_COLUMN_COUNT: number = 3;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly SIX_PERCENT: string = '60%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly NAVI_BAR_WIDTH: string = '40%';
}

// url命名
export enum URL_MAP {
  USER_LOGIN = '/api/hw-atomic/user/login',
  USER_LOGOUT = '/api/hw-atomic/user/logout',
  GET_USER_INFO = '/api/hw-atomic/user/info',
  UPDATE_USER_INFO = '/api/hw-atomic/user/info/update',
  CHECK_IN = '/api/hw-atomic/check/in',
  PEOPLE_LIST = '/api/hw-atomic/people/list',
  PEOPLE_INFO = '/api/hw-atomic/people/info',
  ADD_PEOPLE = '/api/hw-atomic/add/people',
  UPDATE_PEOPLE = '/api/hw-atomic/update/people',
  DELETE_PEOPLE = '/api/hw-atomic/delete/people',
  DEFAULT_PEOPLE = '/api/hw-atomic/default/people',
  VIP_PREPAY = '/api/hw-atomic/vip/prepay',

  ORDER_LIST = '/api/hw-atomic/order/list',
  ORDER_INFO = '/api/hw-atomic/order/info',
  ORDER_COUNT = '/api/hw-atomic/order/count',
  DELETE_ORDER = '/api/hw-atomic/delete/order',
  COMPANY_LIST = '/api/hw-atomic/company/list',
  COUPON_LIST = '/api/hw-atomic/coupon/list',
  ESTIMATED_PRICE = '/api/hw-atomic/estimated/price',
  SERVICE_POINT_LIST = '/api/hw-atomic/service/point/list',
  PREPAY = '/api/hw-atomic/prepay',
  ADD_REMAKE = '/api/hw-atomic/add/remake',
  UPDATE_ORDER = '/api/hw-atomic/update/order',

  TEMPLATE_LIST = '/api/hw-atomic/template/list',
  ADD_TEMPLATE = '/api/hw-atomic/add/template',
  MODIFY_TEMPLATE = '/api/hw-atomic/modify/template',
  DELETE_TEMPLATE = '/api/hw-atomic/delete/template',
  GOODS_LIST = '/api/hw-atomic/goods/list',
}