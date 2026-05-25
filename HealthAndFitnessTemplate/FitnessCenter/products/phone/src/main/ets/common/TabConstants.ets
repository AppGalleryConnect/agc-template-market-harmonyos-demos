
export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  icon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  RECORD,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    icon: $r('app.media.home'),
  },
  {
    id: TabBarType.RECORD,
    title: '预约',
    icon: $r('app.media.booking'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    icon: $r('app.media.mine'),
  },
]

export class PhoneConstants {
  static readonly LEFT_TAB_BAR_WIDTH: number = 96;
  static readonly LEFT_TAB_BAR_ITEM_HEIGHT: number = 100;
  static readonly BOTTOM_TAB_BAR_HEIGHT: number = 52;
}
