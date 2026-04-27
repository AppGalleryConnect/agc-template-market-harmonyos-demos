export interface OrderModuleData {
  id: OrderType;
  title: ResourceStr;
}

export enum OrderType {
  ALL = 0,
  TO_PAY = 1,
  TO_USE = 2,
  COMPLETED = 3,
  REFUNDED = 4
}

export const TICKET_ORDER_MODULE_INFO: OrderModuleData[] = [
  {
    id: OrderType.ALL,
    title: '全部',
  },
  {
    id: OrderType.TO_PAY,
    title: '待支付',
  },
  {
    id: OrderType.TO_USE,
    title: '待使用',
  },
  {
    id: OrderType.COMPLETED,
    title: '已完成',
  },
  {
    id: OrderType.REFUNDED,
    title: '已退订',
  },
];

export const COMMODITY_ORDER_MODULE_INFO: OrderModuleData[] = [
  {
    id: OrderType.ALL,
    title: '全部',
  },
  {
    id: OrderType.TO_PAY,
    title: '待付款',
  },
  {
    id: OrderType.TO_USE,
    title: '待使用',
  },
  {
    id: OrderType.COMPLETED,
    title: '已完成',
  },
  {
    id: OrderType.REFUNDED,
    title: '已退款',
  },
];

export interface StatusInfo {
  text: string,
  color: ResourceStr,
  opacity: number
}