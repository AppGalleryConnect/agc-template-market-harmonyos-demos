import { CourseStatusMap, OrderStatusMap, OrderTabsMap } from 'commonlib';
import { MyCourseTabItem, OrderActionButton, OrderType } from '../types/Index';
import { OrderActionMap, OrderButtonStyleMap } from './Enums';

export const ORDER_TAB_LIST: OrderType[] = [
  {
    type: OrderTabsMap.ALL,
    label: '全部',
    status: [
      OrderStatusMap.PENDING_PAYMENT,
      OrderStatusMap.CANCEL,
      OrderStatusMap.COMPLETE,
      OrderStatusMap.REFUND_IN_PROGRESS,
      OrderStatusMap.REFUNDED,
    ],
  },
  {
    type: OrderTabsMap.PENDING_PAYMENT,
    label: '待支付',
    status: [
      OrderStatusMap.PENDING_PAYMENT,
    ],
  },
  {
    type: OrderTabsMap.COMPLETED,
    label: '已完成',
    status: [
      OrderStatusMap.CANCEL,
      OrderStatusMap.COMPLETE,
    ],
  },
  {
    type: OrderTabsMap.AFTER_SALE,
    label: '售后',
    status: [
      OrderStatusMap.REFUND_IN_PROGRESS,
      OrderStatusMap.REFUNDED,
    ],
  },
];

export const ORDER_ACTION_BUTTON_LIST: OrderActionButton[] = [
  {
    style: OrderButtonStyleMap.OUTLINE,
    action: OrderActionMap.CANCEL_ORDER,
    label: '取消订单',
    orderStatus: OrderStatusMap.PENDING_PAYMENT,
  },
  {
    style: OrderButtonStyleMap.FULFILL,
    action: OrderActionMap.IMMEDIATE_PAYMENT,
    label: '立即支付',
    orderStatus: OrderStatusMap.PENDING_PAYMENT,
  },
  {
    style: OrderButtonStyleMap.OUTLINE,
    action: OrderActionMap.DELETE,
    label: '删除订单',
    orderStatus: OrderStatusMap.COMPLETE,
  },
  {
    style: OrderButtonStyleMap.OUTLINE,
    action: OrderActionMap.REQUEST_REFUND,
    label: '申请退款',
    orderStatus: OrderStatusMap.COMPLETE,
  },
  {
    style: OrderButtonStyleMap.FULFILL,
    action: OrderActionMap.CONTACT_CUSTOMER_SERVICE,
    label: '联系客服',
    orderStatus: OrderStatusMap.COMPLETE,
  },
  {
    style: OrderButtonStyleMap.OUTLINE,
    action: OrderActionMap.DELETE,
    label: '删除订单',
    orderStatus: OrderStatusMap.CANCEL,
  },
  {
    style: OrderButtonStyleMap.FULFILL,
    action: OrderActionMap.REORDER,
    label: '重新下单',
    orderStatus: OrderStatusMap.CANCEL,
  },
  {
    style: OrderButtonStyleMap.OUTLINE,
    action: OrderActionMap.CONTACT_CUSTOMER_SERVICE,
    label: '联系客服',
    orderStatus: OrderStatusMap.REFUND_IN_PROGRESS,
  },
  {
    style: OrderButtonStyleMap.FULFILL,
    action: OrderActionMap.CANCEL_REFUND,
    label: '取消退款',
    orderStatus: OrderStatusMap.REFUND_IN_PROGRESS,
  },
  {
    style: OrderButtonStyleMap.FULFILL,
    action: OrderActionMap.DELETE,
    label: '删除订单',
    orderStatus: OrderStatusMap.REFUNDED,
  },
];

export const MY_COURSE_TAB_LIST: MyCourseTabItem[] = [
  {
    status: CourseStatusMap.IN_PROGRESS,
    label: '在读',
  },
  {
    status: CourseStatusMap.COMPLETED,
    label: '结课',
  },
];

export const WEEKDAY_MAP: Map<number, string> = new Map([
  [0, '周日'],
  [1, '周一'],
  [2, '周二'],
  [3, '周三'],
  [4, '周四'],
  [5, '周五'],
  [6, '周六'],
]);