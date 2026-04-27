export enum RouterMap {
  // 入口
  MAIN = 'Main', // 元服务主页面

  // 首页模块
  CITY_SELECT_PAGE = 'CitySelectPage', // 城市选择页面
  GOOD_DETAIL = 'GoodDetail', // 商品详情页
  ORDER_PAGE = 'OrderPage', // 下单页

  // 我的模块
  MY_ORDER_LIST = 'MyOrderList', // 订单管理页面（包含全部、待付款、已完成、退款售后）
  MY_ORDER_DETAIL = 'MyOrderDetail', // 订单详情
  EDIT_PERSONAL = 'EditPersonal', // 编辑个人信息页面
  COMMON_SERVICE = 'CommonService', // 公共服务
  OFFICIAL_WEB = 'OfficialWeb', // 官网web
}

/**
 * 详情中富文本类型
 */
export enum IntroType {
  IMAGE = 'image',
  TEXT = 'text',
}

export enum TypeGood {
  PAY = 1,
  CONSULT = 2,
}

/**
 * 性别常量
 */
export const GENDER_OPTIONS: string[] = ['男', '女'];

/**
 * 跳转地址管理的参数
 */
export interface IJumpAddrParam {
  selectedId?: number;
  needOnPop?: boolean;
}

/**
 * 商品卡片尺寸
 */
export enum GoodCardSize {
  NORMAL,
  SMALL,
}

/**
 * 卡片参数
 */
export interface IGoodCardParam {
  titleFg: number;
  titleWeight: number;
  showSubTitle: boolean;
  showBtn: boolean;
  symbolFg: number;
  vipPriceFg: number;
  vipPriceWeight: number;
  textConsultFg: number;
  imgAspectRatio: number;
}

/**
 * 商品大卡参数
 */
export const STYLE_GOOD_NORMAL: IGoodCardParam = {
  titleFg: 14,
  titleWeight: 500,
  showSubTitle: true,
  showBtn: true,
  symbolFg: 12,
  vipPriceFg: 14,
  vipPriceWeight: 500,
  textConsultFg: 14,
  imgAspectRatio: 2,
};

/**
 * 商品小卡参数
 */
export const STYLE_GOOD_SMALL: IGoodCardParam = {
  titleFg: 14,
  titleWeight: 500,
  showSubTitle: false,
  showBtn: false,
  symbolFg: 12,
  vipPriceFg: 14,
  vipPriceWeight: 500,
  textConsultFg: 12,
  imgAspectRatio: 1,
};