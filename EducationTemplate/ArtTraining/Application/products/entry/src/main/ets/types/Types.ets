import { CourseTypeMap, OrderTabsMap } from 'commonlib';
import { MainServiceMap, StoreInfoTypeMap, StudyServiceMap } from '../constants/Enums';

export interface TabListItem {
  label: string;
  icon: ResourceStr;
  iconChecked: ResourceStr;
}

export interface MainServiceItem {
  label: string;
  icon: ResourceStr;
  type: MainServiceMap;
}

export interface CourseTypeRadio {
  id: CourseTypeMap;
  value: string;
}

export interface OrderServiceItem {
  label: string;
  icon: ResourceStr;
  type: OrderTabsMap;
  count: number;
}

export interface StudyServiceItem {
  label: string;
  icon: ResourceStr;
  type: StudyServiceMap;
}

export interface StoreInfoItem {
  label: string;
  icon: ResourceStr;
  type: StoreInfoTypeMap;
  value: string;
  showArrow?: boolean;
}

export interface DailyLogActivityItem {
  cover: ResourceStr;
  title: string;
  desc: string;
  price: number;
}