import { CourseInfo, CourseStatusMap, OrderStatusMap, OrderTabsMap } from 'commonlib';
import { OrderActionMap, OrderButtonStyleMap } from '../constants/Enums';

export interface OrderType {
  type: OrderTabsMap;
  label: string;
  status: OrderStatusMap[];
}

export interface OrderActionButton {
  style: OrderButtonStyleMap;
  action: OrderActionMap;
  label: string;
  orderStatus: OrderStatusMap;
}

export interface MyCourseTabItem {
  status: CourseStatusMap;
  label: string;
}

export interface TimetableCourse extends CourseInfo {
  isAddCalendar?: boolean;
}