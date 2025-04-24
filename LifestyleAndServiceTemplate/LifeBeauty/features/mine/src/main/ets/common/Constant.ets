// 订单状态
export interface ITabMenu {
  type: string;
  label: string;
}

export const TAB_MENUS: ITabMenu[] = [
  {
    type: 'total',
    label: '全部',
  },
  {
    type: 'toPay',
    label: '待支付',
  },
  {
    type: 'toUse',
    label: '待使用',
  },
  {
    type: 'finished',
    label: '已完成',
  },
  {
    type: 'refund',
    label: '退款/售后',
  },
];