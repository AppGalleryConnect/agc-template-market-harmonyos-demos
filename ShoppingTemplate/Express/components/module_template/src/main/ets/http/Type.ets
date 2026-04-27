import { IAddrInfo } from 'module_base';

export enum OrderType {
  ALL = '全部',
  SEND = '寄快递',
  RECEIVE = '收快递',
}

export interface IGoods {
  id: number,
  name: string,
  weight: number,
  volume?: number,
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

export interface ISetting {
  text: string,
  value: number,
}

export interface IAddressParam {
  type: OrderType,
  address: IAddrInfo,
}