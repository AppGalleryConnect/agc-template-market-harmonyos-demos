import { TabListItem } from './Types';
import { buildCartPage } from '../tabviews/CartPage';
import { buildCategoryPage } from '../tabviews/CategoryPage';
import { buildHomePage } from '../tabviews/HomePage';
import { buildProfilePage } from '../tabviews/ProfilePage';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.ic_tab_inactive_home'),
    iconChecked: $r('app.media.ic_tab_active_home'),
    component: wrapBuilder(buildHomePage),
  },
  {
    label: '分类',
    icon: $r('app.media.ic_tab_inactive_category'),
    iconChecked: $r('app.media.ic_tab_active_category'),
    component: wrapBuilder(buildCategoryPage),
  },
  {
    label: '购物车',
    icon: $r('app.media.ic_tab_inactive_cart'),
    iconChecked: $r('app.media.ic_tab_active_cart'),
    component: wrapBuilder(buildCartPage),
  },
  {
    label: '我的',
    icon: $r('app.media.ic_tab_inactive_profile'),
    iconChecked: $r('app.media.ic_tab_active_profile'),
    component: wrapBuilder(buildProfilePage),
  },
];
