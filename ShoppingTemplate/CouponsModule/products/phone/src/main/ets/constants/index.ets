import { TabListItem } from 'commonlib';
import { HomePageBuilder, MinePageBuilder, OrderPageBuilder } from 'scenes';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
    component: wrapBuilder(HomePageBuilder),
  },
  {
    label: '订单',
    icon: $r('app.media.ic_order'),
    iconChecked: $r('app.media.ic_order_checked'),
    component: wrapBuilder(OrderPageBuilder),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
    component: wrapBuilder(MinePageBuilder),
  },
];