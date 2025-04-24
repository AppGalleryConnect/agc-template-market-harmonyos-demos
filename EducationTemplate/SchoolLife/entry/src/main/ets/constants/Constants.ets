import { homePageBuilder } from 'home/src/main/ets/pages/HomePage';
import { minePageBuilder } from 'mine';
import { TabListItem } from '../types/Types';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
    component: wrapBuilder(homePageBuilder),
    titleBgColor: $r('sys.color.background_secondary'),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
    component: wrapBuilder(minePageBuilder),
    titleBgColor: Color.White,
  },
];