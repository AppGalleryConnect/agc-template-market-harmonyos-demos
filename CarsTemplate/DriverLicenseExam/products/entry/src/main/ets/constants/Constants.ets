import { TabBarType } from '@ohos_agcit/driver_license_exam_commonlib';
import { TabListItem, MineServiceItem, KEMUTabListItem } from '../types/Types';

export const TAB_LIST: TabListItem[] = [
  {
    label: $r('app.string.home_page'),
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
  },
  {
    label: $r('app.string.mine'),
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
  },
];

export const MINE_LIST:MineServiceItem[] = [

]

export const KEMUTAB_LIST: KEMUTabListItem[] = [
  {
    label: $r('app.string.subject_one')
  },
  {
    label: $r('app.string.subject_two')
  },
  {
    label: $r('app.string.subject_three')
  },
  {
    label: $r('app.string.subject_four')
  },
];

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
}

export class PhoneConstants {
  static readonly LEFT_TAB_BAR_WIDTH: number = 96;
  static readonly LEFT_TAB_BAR_ITEM_HEIGHT: number = 200;
  static readonly BOTTOM_TAB_BAR_HEIGHT: number = 48;
}


