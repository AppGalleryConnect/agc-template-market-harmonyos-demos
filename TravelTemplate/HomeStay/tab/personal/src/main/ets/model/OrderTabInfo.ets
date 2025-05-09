export interface OrderTabBar {
  index: OrderStatusType;
  title: ResourceStr;
  icon?: ResourceStr;
}

export interface OrderTypesTabBar {
  index: OrderStatusType;
  title: ResourceStr;
}

export enum OrderTypes {
  HOTEL = 0,
  COMMODITY = 1,
}

export enum OrderStatusType {
  ALL = 0,
  TO_PAY = 1,
  TO_USE = 2,
  CANCELED = 3,
  COMPLETED = 4
}

export interface OrderType {
  status: number,
  text: string,
  icon: string | Resource
}

export const ORDER_TYPES: Array<OrderType> = [
  {
    status: 1,
    text: '待付款',
    icon: 'app.media.icon_order_pay'
  },
  {
    status: 2,
    text: '待使用',
    icon: 'app.media.icon_order_travel'
  },
  {
    status: 3,
    text: '已取消',
    icon: 'app.media.icon_order_cancel'

  },
  {
    status: 4,
    text: '已完成',
    icon: 'app.media.icon_order_ready'
  }
]

export const ORDER_TYPES_INFO: OrderTypesTabBar[] = [
  {
    index: OrderStatusType.ALL,
    title: '住宿订单',
  },
  {
    index: OrderStatusType.TO_PAY,
    title: '商城订单',
  },
]

export const ORDER_TABS_INFO: OrderTabBar[] = [
  {
    index: OrderStatusType.ALL,
    title: '全部订单',
    icon: $r('app.media.icon_my_order1'),
  },
  {
    index: OrderStatusType.TO_PAY,
    title: '待付款',
    icon: $r('app.media.icon_my_order2'),
  },
  {
    index: OrderStatusType.TO_USE,
    title: '待使用',
    icon: $r('app.media.icon_my_order3'),
  },
  {
    index: OrderStatusType.CANCELED,
    title: '已取消',
    icon: $r('app.media.icon_my_order4'),
  },
  {
    index: OrderStatusType.COMPLETED,
    title: '已完成',
    icon: $r('app.media.icon_my_order5'),
  },
];