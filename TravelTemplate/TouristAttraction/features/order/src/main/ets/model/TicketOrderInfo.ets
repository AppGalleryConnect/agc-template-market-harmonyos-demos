import { OrderBasicInfo } from 'types';

@ObservedV2
export class TicketOrderInfo implements OrderBasicInfo {
  couponId: number = 0;
  orderNo: string = '';
  orderTime: string = '';
  orderStatus: number = 0;
  count: number = 0;
  touristId: number[] = [];
  contactId: number = 0;
  productName: string = '';
  productPrice: number = 0;
  discount: number = 0;
  amount: number = 0;
  startTime: string = '';
  endTime: string = '';
  isAddSchedule: boolean = false;
}

export class TicketOrderList extends Array<TicketOrderInfo> {
}
