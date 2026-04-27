import { TabSingleItem } from '../viewmodel/TabSingleItem';
import { TranslateHomePageBuilder } from 'home';
import { MinePage } from 'person';

/**
 * @usage: tab 页面控制类，包括首页、我的
 * @layout:
 * @constraints: tab 页面控制类，包括首页（home）、我的（person）。
 * 根据用户实际需求仅修改代码中 TAB_CONFIG 变量，当前仅支持删除变量中的元素，以及修改 id，从 0 开始并保证 id 顺序，其他元素不允许修改。
 * 根据用户需求删除多余的 import 依赖，仅从home、person 依赖中删除，TabSingleItem 依赖需保留。
 * @fileType: tab
 * @isGen: true
 */
@Builder
function minePageBuilder() {
  MinePage()
}

// Tab配置常量
export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.home'),
    index: 0,
    fontColor: '#99000000',
    fontColorActive: '#46B1E3',
    icon: $r('app.media.ic_public_home'),
    iconActive: $r('app.media.ic_public_home_filled'),
    component: wrapBuilder(TranslateHomePageBuilder),
  },
  {
    label: $r('app.string.person'),
    index: 1,
    fontColor: '#99000000',
    fontColorActive: '#46B1E3',
    icon: $r('app.media.ic_person'),
    iconActive: $r('app.media.ic_person_filled'),
    component: wrapBuilder(minePageBuilder),
  },
];
