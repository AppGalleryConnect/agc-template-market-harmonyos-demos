import { OrderBasicInfo } from 'types'
import { OrderType, StatusInfo } from './OrderModuleInfo'

@ObservedV2
export class TicketOrderInfo implements OrderBasicInfo {
  couponId: number = 0
  orderNo: string = ''
  orderTime: string = ''
  orderStatus: number = 0
  count: number = 0
  touristId: number[] = []
  contactId: number = 0
  productName: string = ''
  productPrice: number = 0
  discount: number = 0
  amount: number = 0
  startTime: string = ''
  endTime: string = ''
}

export class TicketOrderList extends Array<TicketOrderInfo> {
}

export const TICKET_ORDER_INFO_MAP: StatusInfo[] = [
  {
    text: '全部',
    color: '#E84026',
    opacity: 1
  },
  {
    text: '待支付',
    color: '#E84026',
    opacity: 1
  },
  {
    text: '待使用',
    color: '#64BB5C',
    opacity: 1
  },
  {
    text: '已完成',
    color: '#000000',
    opacity: 1
  },
  {
    text: '已退订',
    color: '#000000',
    opacity: 1
  }
]


