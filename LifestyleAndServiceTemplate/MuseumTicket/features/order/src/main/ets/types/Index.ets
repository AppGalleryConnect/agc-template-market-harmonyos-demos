export enum OrderClass {
  PENDING_USE = '1',
  PENDING_PAYMENT = '2',
  USED = '3',
  EXPIRED = '4',
  INVALIDATION = '5'
}

export interface OrderTabListItem {
  label: string,
  type: OrderClass,
  icon: ResourceStr
}

export interface OrderInfo {
  orderNo: string,
  visitTime: string,
  orderTime: string,
  visitor: number,
  status: string,
  actualPay?: number,
  orderAmount?: number,
  cancelTime?: string,
  placeTime?: string,
  payTime?: string,
  performanceName: string,
  orderStr?: string
}


export enum TicketStatus {
  NOTHING = '2',
  HAVE = '1',
  CLOSED = '3',
}

export enum TimeStatus {
  MORNING = '1',
  AFTERNOON = '2'
}

// 免费约展时间信息
export interface DayTicketInfo {
  date: Date,
  day: string,
  total: number,
  statusCn: string,
  status: string,
  morningAmount: number,
  afternoonAmount: number
}


export interface DateItem {
  date: Date;
  label: string;
}


export interface TotalInfo {
  total: number,
  totalPrice: number
}

// 常用联系人 (获取，修改，新增)
export interface Contacts {
  personID: string,
  cardType: string,
  name: string,
  phone: string,
  cardID: string
}


