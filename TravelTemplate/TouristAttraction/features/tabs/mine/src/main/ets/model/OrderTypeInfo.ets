import { Constant } from 'common';

export interface OrderTypeInfo {
  type: OrderType;
  name: ResourceStr;
  icon: ResourceStr;
  click: (event: ClickEvent) => void;
}

export enum OrderType {
  TICKET = 0,
  COMMODITY = 1,
}

export function getOrderTypeInfo(pathStack: NavPathStack) {
  return [
    {
      type: OrderType.TICKET,
      name: '门票订单',
      icon: $r('app.media.ticket_order'),
      click: () => {
        pathStack.pushPathByName('OrderView', OrderType.TICKET);
      },
    },
    {
      type: OrderType.COMMODITY,
      name: '购物订单',
      icon: $r('app.media.commodity_order'),
      click: () => {
        pathStack.pushPathByName('OrderView', OrderType.COMMODITY);
      },
    },
  ] as OrderTypeInfo[];
}