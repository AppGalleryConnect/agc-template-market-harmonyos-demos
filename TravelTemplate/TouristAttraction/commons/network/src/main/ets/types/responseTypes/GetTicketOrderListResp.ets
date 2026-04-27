export interface TicketOrderListItem {
  orderNo: string;
  orderTime: string;
  orderStatus: number;
  count: number;
  touristId: string[];
  contactId: string;
  productName: string
  productPrice: number
  discount: number
  amount: number
  startTime: string;
  endTime: string;
  isAddSchedule: boolean
  isAddSubscription: boolean
}

export class GetTicketOrderListResp extends Array<TicketOrderListItem> {
}