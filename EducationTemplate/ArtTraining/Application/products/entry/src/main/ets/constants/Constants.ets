import { CourseTypeMap, OrderTabsMap } from 'commonlib';
import {
  CourseTypeRadio,
  MainServiceItem,
  OrderServiceItem,
  StoreInfoItem,
  StudyServiceItem,
  TabListItem,
} from '../types/Types';
import { MainServiceMap, StoreInfoTypeMap, StudyServiceMap } from './Enums';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_tab_home'),
    iconChecked: $r('app.media.ic_tab_home_checked'),
  },
  {
    label: '课程中心',
    icon: $r('app.media.ic_tab_courses'),
    iconChecked: $r('app.media.ic_tab_courses_checked'),
  },
  {
    label: '打卡活动',
    icon: $r('app.media.ic_tab_punching'),
    iconChecked: $r('app.media.ic_tab_punching_checked'),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_tab_mine'),
    iconChecked: $r('app.media.ic_tab_mine_checked'),
  },
];

export const MAIN_SERVICE_LIST: MainServiceItem[] = [
  {
    label: '课程中心',
    icon: $r('app.media.ic_home_service1'),
    type: MainServiceMap.COURSES_COLUMN,
  },
  {
    label: '直播课程',
    icon: $r('app.media.ic_home_service2'),
    type: MainServiceMap.ONLINE_COURSES,
  },
  {
    label: '关于我们',
    icon: $r('app.media.ic_home_service3'),
    type: MainServiceMap.ABOUT_US,
  },
  {
    label: '附近门店',
    icon: $r('app.media.ic_home_service4'),
    type: MainServiceMap.OFFLINE_STORE,
  },
];

export const COURSE_TYPE_RADIO_GROUP = 'courseType';

export const COURSE_TYPE_RADIO_LIST: CourseTypeRadio[] = [
  {
    id: CourseTypeMap.ALL,
    value: '全部',
  },
  {
    id: CourseTypeMap.ONLINE,
    value: '直播课',
  },
  {
    id: CourseTypeMap.OFFLINE,
    value: '线下课',
  },
];

export const ORDER_SERVICE_LIST: OrderServiceItem[] = [
  {
    label: '全部',
    icon: $r('app.media.ic_order_all'),
    type: OrderTabsMap.ALL,
    count: 1,
  },
  {
    label: '待付款',
    icon: $r('app.media.ic_order_paying'),
    type: OrderTabsMap.PENDING_PAYMENT,
    count: 1,
  },
  {
    label: '已完成',
    icon: $r('app.media.ic_order_completed'),
    type: OrderTabsMap.COMPLETED,
    count: 0,
  },
  {
    label: '售后',
    icon: $r('app.media.ic_order_service'),
    type: OrderTabsMap.AFTER_SALE,
    count: 0,
  },
];

export const STUDY_SERVICE_LIST: StudyServiceItem[] = [
  {
    label: '已购课程',
    icon: $r('app.media.ic_study_course'),
    type: StudyServiceMap.COURSES,
  },
  {
    label: '课程表',
    icon: $r('app.media.ic_study_schedule'),
    type: StudyServiceMap.TIMETABLE,
  },
  {
    label: '我的打卡',
    icon: $r('app.media.ic_study_punching'),
    type: StudyServiceMap.CHECK_IN,
  },
  {
    label: '学员证',
    icon: $r('app.media.ic_study_id_card'),
    type: StudyServiceMap.ID_CARD,
  },
];

export const STORE_INFO_LIST: StoreInfoItem[] = [
  {
    label: '联系地址',
    icon: $r('app.media.ic_address'),
    type: StoreInfoTypeMap.LOCATION,
    value:'',
  },
  {
    label: '联系客服',
    icon: $r('app.media.ic_contact_us'),
    type: StoreInfoTypeMap.PHONE,
    showArrow: true,
    value:'',
  },
  {
    label: '营业时间',
    icon: $r('app.media.ic_business_hour'),
    type: StoreInfoTypeMap.BUSINESS_TIME,
    value:'',
  },
  {
    label: '设置',
    icon: $r('app.media.ic_about_us'),
    type: StoreInfoTypeMap.ABOUT_US,
    showArrow: true,
    value:'',
  },
];
