import { IAddrInfo } from 'module_base';
import { Coupon } from '../../../../Index';
import { ExpressStatus, OrderStatus, OrderType, PaymentMethod, ShippingMethod } from '../common/Constant';

/**
 * 用户信息
 */
export interface IUserInfo {
  isLogin: boolean,
  id: number;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  avatar: string;
  isVip: boolean,
  points: number,
  couponList: Coupon[]
  realNameAuthFlag: number,
}

/**
 * 坐标信息
 */
export interface IPosition {
  latitude: number,
  longitude: number
}

/**
 * 物品信息
 */
export interface IGoods {
  id: number,
  name: string,
  weight: number,
  volume?: number,
}

/**
 * 订单信息
 */
export interface IOrder {
  id: number,
  type: OrderType,
  status: OrderStatus,
  expressStatus: ExpressStatus,
  companyName: string,
  orderNo: string,
  remark: string,
  deliveryTime: string,
  receiptTime: string,
  price: number,
  sendAddress: IAddrInfo,
  getAddress: IAddrInfo,
  shippingMethod: ShippingMethod,
  goods: IGoods,
  day: string,
  time: string,
  paymentMethod: PaymentMethod,
  servicePointId?: number,
  grid?: string,
  couponId?: number,
  mailCode: number
}

/**
 * 快递员信息
 */
export interface ICourier {
  name: string,
  cellphone: string,
  image?: string,
}

export interface ILogisticsInfo {
  time: string,
  content: string,
}

/**
 * 订单详情
 */
export interface IOrderInfo {
  id: number,
  type: OrderType,
  status: OrderStatus,
  expressStatus: ExpressStatus,
  price: number,
  companyName: string,
  goods: IGoods,
  sendAddress: IAddrInfo,
  getAddress: IAddrInfo,
  sendPosition: string,
  getPosition: string,
  orderNo: string,
  courier: ICourier,
  logisticsInfo: ILogisticsInfo[],
  origins: IPosition,
  destination: IPosition,
  waypoints: IPosition[],
  shippingMethod: ShippingMethod,
  day: string,
  time: string,
  paymentMethod: PaymentMethod,
  servicePointId?: number,
  grid?: string,
  couponId?: number,
  mailCode: number
}

// 快递公司
export interface ICompany {
  id: number,
  name: string,
}

// 服务点
export interface IServicePoint {
  id: number,
  name: string,
  image: string,
  title: string,
  tips: string[],
  distance: string,
  positionName: string,
  position: IPosition,
}


//支付
export interface IPrepay {
  id: number,
  orderNo: string;
  orderStr: string;
  timestamp: string;
}

export interface IAddrInfoDetail {
  id: string,
  name: string,
  cellphone: string,
  province: string,
  city: string,
  district: string,
  street: string,
  detail: string,
  isDefault: boolean,
  orderType: OrderType
}


export interface ITemplate {
  id: number,
  name: string,
  sendAddress: IAddrInfo,
  getAddress: IAddrInfo,
  goods: IGoods,
  shippingMethod: number,
  paymentMethod: number,
  weight: number,
  time?: string,
}

export interface IAddressParam {
  type: OrderType,
  address: IAddrInfo,
}