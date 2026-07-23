import { TabListItem } from './Types';
import { buildCartPage } from '../tabviews/CartPage';
import { buildCategoryPage } from '../tabviews/CategoryPage';
import { buildHomePage } from '../tabviews/HomePage';
import { buildProfilePage } from '../tabviews/ProfilePage';

export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('sys.symbol.house_fill'),
    component: wrapBuilder(buildHomePage),
  },
  {
    label: '分类',
    icon: $r('sys.symbol.square_fill_grid_2x2'),
    component: wrapBuilder(buildCategoryPage),
  },
  {
    label: '购物车',
    icon: $r('sys.symbol.cart_fill'),
    component: wrapBuilder(buildCartPage),
  },
  {
    label: '我的',
    icon: $r('sys.symbol.person_fill'),
    component: wrapBuilder(buildProfilePage),
  },
];
