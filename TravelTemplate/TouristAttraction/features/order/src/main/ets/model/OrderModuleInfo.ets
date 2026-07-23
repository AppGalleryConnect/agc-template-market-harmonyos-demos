export interface OrderModuleData {
  id: OrderType;
  title: ResourceStr;
}

export enum OrderType {
  ALL = 0, TO_PAY = 1, TO_USE = 2, COMPLETED = 3, REFUNDED = 4
}

export const TICKET_ORDER_MODULE_INFO: OrderModuleData[] = [{
  id: OrderType.ALL, title: '全部',
}, {
  id: OrderType.TO_PAY, title: '待支付',
}, {
  id: OrderType.TO_USE, title: '待使用',
}, {
  id: OrderType.COMPLETED, title: '已完成',
}, {
  id: OrderType.REFUNDED, title: '已退订',
}];

export const COMMODITY_ORDER_MODULE_INFO: OrderModuleData[] = [{
  id: OrderType.ALL, title: '全部',
}, {
  id: OrderType.TO_PAY, title: '待付款',
}, {
  id: OrderType.TO_USE, title: '待使用',
}, {
  id: OrderType.COMPLETED, title: '已完成',
}, {
  id: OrderType.REFUNDED, title: '已退款',
}];

export interface StatusInfo {
  text: string,
  color: ResourceStr,
}

export const ORDER_INFO_MAP: StatusInfo[] = [{
  text: '全部', color: $r('sys.color.font_primary'),
}, {
  text: '待支付', color: $r('sys.color.warning'),
}, {
  text: '待使用', color: $r('sys.color.multi_color_04'),
}, {
  text: '已完成', color: $r('sys.color.font_primary'),
}, {
  text: '已退订', color: $r('sys.color.font_secondary'),
}];