import { DevicePageBuilder } from 'device';
import { HealthPageBuilder } from 'health';
import { MinePageBuilder } from 'person';
import { TabSingleItem } from '../viewmodel/TabSingleItem';

/**
 * @usage: tab 页面控制类，包括健康、设备、我的
 * @layout:
 * @constraints: tab 页面控制类，包括健康（health）、设备（device）、我的（person）。
 * 根据用户实际需求仅修改代码中 TAB_CONFIG 变量，当前仅支持删除变量中的元素，以及修改 id，从 0 开始并保证 id 顺序，其他元素不允许修改。
 * 根据用户需求删除多余的 import 依赖，仅从 device、health、person 依赖中删除，TabSingleItem 依赖需保留。
 * @isGen: true
 * @fileType: tab
 */
export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.health_tab'),
    index: 0,
    fontColor: '#66000000',
    fontColorActive: '#FF117CFF',
    icon: $r('app.media.health_tab'),
    iconActive: $r('app.media.health_tab_active'),
    component: wrapBuilder(HealthPageBuilder),
  },
  {
    label: $r('app.string.device_tab'),
    index: 1,
    fontColor: '#66000000',
    fontColorActive: '#FF117CFF',
    icon: $r('app.media.device_tab'),
    iconActive: $r('app.media.device_tab_active'),
    component: wrapBuilder(DevicePageBuilder),
  },
  {
    label: $r('app.string.person_tab'),
    index: 2,
    fontColor: '#66000000',
    fontColorActive: '#FF117CFF',
    icon: $r('app.media.person_tab'),
    iconActive: $r('app.media.person_tab_active'),
    component: wrapBuilder(MinePageBuilder),
  },
];

export const tenAM = '10';

export const threePM = '15';

export const sevenPM = '19';

export const tenPM = '22';

export const fiveMinutes = 1000 * 60 * 5;