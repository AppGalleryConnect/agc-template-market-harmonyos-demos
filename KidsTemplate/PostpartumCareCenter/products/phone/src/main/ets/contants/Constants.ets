import { TabListItem } from '../model/TabListItem';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
  },
  {
    label: '门店',
    icon: $r('app.media.ic_stores'),
    iconChecked: $r('app.media.ic_stores_checked'),
  },
  {
    label: '活动',
    icon: $r('app.media.ic_activities'),
    iconChecked: $r('app.media.ic_activities_checked'),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
  },
];