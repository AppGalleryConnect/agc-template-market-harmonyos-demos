import { TabListItem } from 'entry/ets/types/Types';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
  },
  {
    label: '出行导航',
    icon: $r('app.media.ic_trip'),
    iconChecked: $r('app.media.ic_trip_checked'),
  },
  {
    label: '乘车码',
    icon: $r('app.media.ic_qrcode'),
    iconChecked: $r('app.media.ic_qrcode_checked'),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
  },
];
