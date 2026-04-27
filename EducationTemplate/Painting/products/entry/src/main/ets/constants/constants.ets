import { HomeDrawingPageBuilder } from 'home';
import { MinePageBuilder } from 'person';
import { TabSingleItem } from '../viewmodels/TabSingleItem';

/**
 * @usage: tab 页面控制器，包括绘画、我的
 * @layout:
 * @constraints: tab 页面控制器包括绘画（home）、我的（person）。根据用户实际需求仅修改代码中 TAB_CONFIG 变量，
 * 当前仅支持删除变量中的元素，以及修改 index，从 0 开始并保证 index 顺序，其他元素不允许修改。
 * 根据用户需求删除多余的 import 依赖，仅从 home、person 依赖中删除，TabSingleItem 依赖需保留。
 * @isGen: true
 * @fileType: tab
 */
export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.home_tab'),
    index: 0,
    fontColor: '#66000000',
    fontColorActive: '#FFED6F21',
    icon: $r('app.media.home_tab'),
    iconActive: $r('app.media.home_tab_active'),
    component: wrapBuilder(HomeDrawingPageBuilder),
  },
  {
    label: $r('app.string.person_tab'),
    index: 1,
    fontColor: '#66000000',
    fontColorActive: '#FFED6F21',
    icon: $r('app.media.person_tab'),
    iconActive: $r('app.media.person_tab_active'),
    component: wrapBuilder(MinePageBuilder),
  },
];