import { AppointState, OrderType } from '../common/Constant';

/**
 * 创建预约
 */
export interface ICreateAppointmentRequest {
  // 联系人姓名
  name: string;

  // 联系人手机号
  phone: string;

  // 预约时间，时间戳类型
  reserveTime: string;

  // 预约的项目ID
  goodId: string;

  // 预约备注
  remarks: string;

  // 预约人数
  numbers: string;
}

/**
 * 更新预约
 */
export interface IUpdateAppointmentRequest {
  // 预约ID
  reserveId: number;

  // 是否设置日程，值为1表示设置了日程，0取消日程
  setSchedule: number;

  // 是否设置订阅，值为1表示设置了订阅，0取消订阅
  setSubscription: number;
}

/**
 * 静默登录请求内容
 */
export interface ILoginWithHuaweiIDRequest {
  clientId: string;
  code: string;
  idToken: string;
  openId: string;
  unionId: string;
}

export interface IBindCodeRequest {
  code: string;
}

export interface IRebindConfirmRequest {
  rebindSecret: string;
}

export interface ICancelReserveRequest {
  // 预约ID
  reserveId: number;
}

export interface IActiveMemberRequest {
  name: string;
  gender: string;
  mobile: string;
  birth: number;
}

export interface ISubmitOrderRequest {
  // 项目id
  projectId: number;

  // 类型，团购还是次卡
  type: OrderType;

  // 联系人姓名
  contactName: string;

  // 联系人电话
  contactPhone: string;

  // 备注信息
  remark: string;

  // 订购的数量
  numbers: number;

  // 实际付款
  actualPay: number;
}

export interface IRefundGroup {
  orderNo: string;
}

export interface IQueryAppointList {
  status: AppointState[];
}