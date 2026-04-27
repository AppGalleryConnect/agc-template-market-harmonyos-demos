import { BaseResponse } from './BaseResponse';
import { OrderSkuItem, OrderExpressInfo, OrderItem, PickupStoreInfo } from '../OrderTypes';

export interface PreOrderResp extends BaseResponse {
  skuList: OrderSkuItem[];
  totalPrice: number;
}

export interface OrderListResp extends BaseResponse {
  total: number;
  curPage: number;
  orderList: OrderItem[];
  isFinal: boolean;
}

export interface OrderDetailResp extends BaseResponse {
  detail: OrderItem;
}

export interface OrderCreateResp extends BaseResponse {
  orderNo: string;
  orderStr: string;
  detail: OrderItem;
}

export interface OrderExpressResp extends BaseResponse {
  info: OrderExpressInfo
}

/** 默认自提门店响应 */
export interface DefaultPickupStoreResp extends BaseResponse {
  data: PickupStoreInfo;
}
