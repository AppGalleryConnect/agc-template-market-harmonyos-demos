import { IAddrInfo } from 'module_base';
import { ExpressStatus, OrderStatus, OrderType, PaymentMethod, ShippingMethod } from '../common/Constant';
import { IGoods } from './IResponse';

export interface NormalRequest {
  id: number
}

// 支付订单
export interface IPrepayRequest {
  sendAddress: IAddrInfo,
  getAddress: IAddrInfo,
  goodsInfo: IGoods,
  payMethod: PaymentMethod,
  shippingMethod: ShippingMethod,
  expressCompanyId?: number,
  day?: string,
  time?: string,
  servicePointId?: number,
  grid?: string,
  couponId?: number,
}

//支付vip
export interface IVipPrepayRequest {
  id: number,
  userId: number,
  price: number,
}

//获取优惠券
export interface ICouponRequest {
  isVip: boolean
}

// 获取当前条件的快递
export interface GetOrderListRequest {
  orderNo?: string;
  cellphone?: string,
  type?: OrderType,
  status?: OrderStatus,
  expressStatus?: ExpressStatus
}

export interface UpdateOrderRequest {
  expressCompanyId?: number | undefined;
  id?: number,
  sendAddress?: IAddrInfo,
  getAddress?: IAddrInfo,
  expressStatus?: ExpressStatus,
  goodsInfo?: IGoods,
  paymentMethod?: PaymentMethod,
  companyId?: number,
  day?: string,
  time?: string,
  servicePointId?: number,
  grid?: string,
  couponId?: number,
}

export interface RemakeRequest {
  id: number,
  remake: string,
}
