import { OrderBasicInfo } from './OrderBasicInfo'

@ObservedV2
export class TicketOrderInfo implements OrderBasicInfo {
  orderNo: string = ''
  orderTime: string = ''
  orderStatus: number = 0
  couponId: number = 0
  count: number = 0
  touristId: string[] = []
  contactId: string = ''
  productName: string = ''
  amount: number = 0
  productPrice: number = 0
  startTime: string = ''
  endTime: string = ''
  discount: number = 0
}

export class TicketOrderList extends Array<TicketOrderInfo> {
}