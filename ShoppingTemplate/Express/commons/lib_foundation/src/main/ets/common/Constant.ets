import { ValueType } from '@kit.ArkData';
import { ISetting } from '../model/CommonModel';
import { ITime, ParcelStatus, PayMethod, ShippingMethod } from './CommonEnum';


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
 * 数据库操作
 */
export enum DBOperator {
  EQUAL,
  NOT_EQUAL,
  GREATER,
  GREATER_OR_EQUAL,
  LESS,
  LESS_OR_EQUAL,
  LIKE,
  IS_NULL,
  IS_NOT_NULL,
  BEGIN_WITH,
  END_WITH,
  CONTAIN,
  ORDER_BY_DESC,
}

/**
 * 数据库错误码
 */
export enum DBOperationErrorCode {
  NO_STORE = -100,
  INSERT_ERROR = -101,
  UPDATE_ERROR = -102,
  DELETE_ERROR = -103,
  QUERY_ERROR = -104,
}

// 表结构定义类型
export interface TableSchema {
  tableName: string;
  createSQL: string;
  indexes?: string[];
}

export interface TablePredicate {
  field: string;
  value: ValueType;
  operator: DBOperator;
}

/**
 * 常量类
 */
export class CommonConstants {
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
  // 用户登录
  USER_LOGIN = '/api/hw-atomic/user/login',
  // 用户登出
  USER_LOGOUT = '/api/hw-atomic/user/logout',
  // 读取用户信息
  GET_USER_INFO = '/api/hw-atomic/user/info',
  // 更新用户信息
  UPDATE_USER_INFO = '/api/hw-atomic/user/info/update',

  // 查询用户本周签到数据
  WEEKLY_SIGN = '/api/hw-atomic/sign/info',
  // 签到操作
  DO_SIGN = '/api/hw-atomic/sign/do',
  // 新增积分明细
  ADD_POINTS_DETAIL = '/api/hw-atomic/points/add',
  // 查询积分明细
  POINTS_HISTORY = '/api/hw-atomic/points/history',
  // 查询每日任务
  DAILY_TASK = '/api/hw-atomic/task/list',
  // 完成任务，领取积分
  CLAIM_TASK_REWARD = '/api/hw-atomic/task/claim_reward',

  // 地址列表
  ADDRESS_LIST = '/api/hw-atomic/address/list',
  // 默认地址
  DEFAULT_ADDRESS = '/api/hw-atomic/address/default',
  // 新增地址
  ADD_ADDRESS = '/api/hw-atomic/address/add',
  // 更新地址
  UPDATE_ADDRESS = '/api/hw-atomic/address/update',
  // 删除地址
  DELETE_ADDRESS = '/api/hw-atomic/address/delete',

  // 创建订单
  CREATE_ORDER = '/api/hw-atomic/order/create',
  // 订单列表
  ORDER_LIST = '/api/hw-atomic/order/list',
  // 订单列表最新一条数据
  ORDER_LATEST = '/api/hw-atomic/order/latest',
  // 订单详情
  ORDER_DETAIL = '/api/hw-atomic/order/detail',
  // 更新订单
  UPDATE_ORDER = '/api/hw-atomic/order/update',
  // 删除订单
  DELETE_ORDER = '/api/hw-atomic/order/delete',
  // 创建物流轨迹
  CREATE_LOGISTICS = '/api/hw-atomic/logistics/create',
  // 查询运单的物流轨迹个数
  LOGISTICS_COUNT = '/api/hw-atomic/logistics/count',
  // 自动补全物流轨迹
  AUTO_UPDATE_LOGISTICS = '/api/hw-atomic/logistics/autoUpdate',

  // 获取快递公司列表
  COMPANY_LIST = '/api/hw-atomic/company/list',
  // 查询用户优惠券列表
  USER_COUPON_LIST = '/api/hw-atomic/coupon/list',
  // 查询福利页优惠券列表
  COUPON_TEMPLATE_LIST = '/api/hw-atomic/coupon/template/list',
  // 领取或兑换优惠券
  CLAIM_COUPON = '/api/hw-atomic/coupon/claim',
  // 一键领取会员权益优惠券
  BATCH_CLAIM_COUPON = '/api/hw-atomic/coupon/claim/batch',
  // 判断是否存在还未领取的会员权益优惠券
  HAS_UN_CLAIM_COUPON = '/api/hw-atomic/coupon/claim/check-coupon',
  // 使用优惠券
  USE_COUPON = '/api/hw-atomic/coupon/use',
  // 退还优惠券
  REFUND_COUPON = '/api/hw-atomic/coupon/refund',
  // 获取服务点列表
  SERVICE_POINT_LIST = '/api/hw-atomic/service/point/list',

  // 查询寄件模板列表
  TEMPLATE_LIST = '/api/hw-atomic/template/list',
  // 新增寄件模板
  ADD_TEMPLATE = '/api/hw-atomic/template/add',
  // 查询模板详情
  TEMPLATE_DETAIL = '/api/hw-atomic/template/detail',
  // 更新寄件模板
  UPDATE_TEMPLATE = '/api/hw-atomic/template/update',
  // 删除寄件模板
  DELETE_TEMPLATE = '/api/hw-atomic/template/delete',
  // 查询物品类型列表
  GOODS_LIST = '/api/hw-atomic/goods/list',
}

export const TIME_LIST: string[] = [
  '8:00 - 9:00', '9:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00',
  '13:00 - 14:00', '14:00 - 15:00', '15:00 - 16:00', '16:00 - 17:00',
  '17:00 - 18:00', '18:00 - 19:00', '19:00 - 20:00'
]

export const DAY_LIST: ITime[] = [
  {
    text: '今天',
    value: 0,
    timeList: TIME_LIST
  },
  {
    text: '明天',
    value: 1,
    timeList: TIME_LIST
  },
  {
    text: '后天',
    value: 2,
    timeList: TIME_LIST
  }
]

export function getTimeList(dayList: ITime[]): ITime[] {
  const data: ITime[] = []
  dayList.forEach((item) => {
    const temp: ITime = {
      text: item.text,
      value: item.value,
      timeList: item.timeList
    }
    data.push(temp)
  })
  const time = new Date().getHours()
  if (time < 8) {
    return data;
  }

  if (time >= 20) {
    return data.slice(1);
  }

  const count = time - 8
  if (count < 10) {
    data[0].timeList = data[0].timeList.slice(count);
    data[0].timeList.unshift('一小时内');
  } else {
    data.shift()
  }
  return data
}

export const methodList: ISetting[] = [
  {
    text: '上门取件',
    value: 1,
  },
  {
    text: '服务点自寄',
    value: 2,
  },
]

export const PAY_METHOD_LIST: ISetting[] = [
  {
    text: '寄付现结',
    value: PayMethod.PREPAID,
  },
  {
    text: '到付',
    value: PayMethod.CASH_DELIVERY,
  },
]

export const GRID_LIST: ISetting[] = [
  {
    text: '小格口',
    value: 1,
  },
  {
    text: '中格口',
    value: 2,
  },
  {
    text: '大格口',
    value: 3,
  },
]

export const SHIPPING_METHOD_LIST: ISetting[] = [
  {
    text: '网点自寄',
    value: ShippingMethod.SELF_DELIVERY,
  },
  {
    text: '自行联系快递员',
    value: ShippingMethod.CONTACT_COURIER,
  },
  {
    text: '每天固定时间',
    value: ShippingMethod.DAILY_PICKUP,
  },
]

export const STATUS_MAP = [
  '待取件', '待入柜', '已取件', '运送中', '派送中', '待签收', '已签收', '已取消'
]

// 格口价格
export const GRID_PRICE = {
  '小格口': 2,
  '中格口': 4,
  '大格口': 6
} as Record<string, number>

export const DEFAULT_LATITUDE = 31.97;
export const DEFAULT_LONGITUDE = 118.75;

// 状态与描述的映射 (用于界面展示)
export const STATUS_DESCRIPTION_MAP: Map<number, string> = new Map([
  [ParcelStatus.AWAITING_PICKUP, '快递已下单，等待快递员取件'],
  [ParcelStatus.PENDING_LOCKER, '快递已下单，包裹待入柜'],
  [ParcelStatus.COLLECTED, '快递员【operatorName，联系电话：operatorPhone】已取件，正在赶往分拨中心'],
  [ParcelStatus.IN_TRANSIT, '快件已到达【senderCity分拨中心】，准备发往【receiverCity分拨中心】'],
  [ParcelStatus.DELIVERY, '快件已到达【receiverCity分拨中心】，派件交给【operatorName，联系电话：operatorPhone】，正在派送途中（如有任何问题可优先联系我，我将尽全力为您解决，您的认可，是我最大的动力！）'],
  [ParcelStatus.OUT_FOR_DELIVERY, '快件已由快递员【operatorName，联系电话：operatorPhone】送达代收点，请及时签收'],
  [ParcelStatus.DELIVERED, '您的快件已由本人签收，如有疑问请电话联系快递员。您的体验对于我们至关重要，如果您对我们有任何想法或建议，请随时联系我们，我们一定用心倾听，全力改进，不辜负您的信任和支持。'],
  [ParcelStatus.CANCELED, '已取消寄件']
]);

// 状态和快递员的映射
export const STATUS_OPERATOR_MAP: Map<number, string[]> = new Map([
  [ParcelStatus.COLLECTED, ['张师傅', '13811112222']],
  [ParcelStatus.DELIVERY, ['王小二', '13933334444']],
  [ParcelStatus.OUT_FOR_DELIVERY, ['王小二', '13933334444']],
])

// 定义演进规则：下单后多长时间（毫秒）达到什么状态
export const RULES: Record<string, number>[] = [
  { 'offset': 0, 'status': ParcelStatus.AWAITING_PICKUP },
  { 'offset': 1 * 60 * 60 * 1000, 'status': ParcelStatus.COLLECTED },
  { 'offset': 6 * 60 * 60 * 1000, 'status': ParcelStatus.IN_TRANSIT },
  { 'offset': 8 * 60 * 60 * 1000, 'status': ParcelStatus.DELIVERY },
  { 'offset': 12 * 60 * 60 * 1000, 'status': ParcelStatus.OUT_FOR_DELIVERY },
  { 'offset': 24 * 60 * 60 * 1000, 'status': ParcelStatus.DELIVERED },
]

// 服务卡片
export const KEY_CARD_ID = 'card_id';
export const KEY_CARD_INFO = 'card_data';

export const WEIGHT_PRICE_PER_KG = 1.2;
export const DISTANCE_PRICE_PER_KM = 0.015;
export const MIN_DISTANCE_PRICE = 3;