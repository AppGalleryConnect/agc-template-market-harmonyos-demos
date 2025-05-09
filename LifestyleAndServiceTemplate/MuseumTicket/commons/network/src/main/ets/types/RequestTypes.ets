import { TicketOwner } from './ResponseTypes';

export interface BaseSuccessResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}


export interface OrderListRequest {
  orderClass: string,
  userId: number
}

export interface CancelOrderRequest {
  orderNo: string,
  userId: number,
  cancelTime: string
}

export interface OrderDetailRequest {
  orderNo: string,
  userId: number,
}

// 订单参观人信息
interface OrderVisitor {
  personId: string,
  name: string,
}

export interface OrderFreeRequest {
  visitTime: string,
  orderTime: string,
  visitor: number,
  visitors: OrderVisitor[],
  contactPhone: string,
}


// 订单信息
export interface PrepayBuyTicketRequest {
  visitTime: string,
  orderAmount?: number,
  ticketOwner: TicketOwner[]
  contactPhone: string,
  performanceName: string,
  performanceId: string
}


export interface GetBannerImgRequest{
  pageType:number
}