export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  defaultIcon: ResourceStr;
}

export enum TabBarType {
  HOME_PAGE = 0,
  ORDER,
  ORDER_LIST,
  MINE
}

export const TABS_INFO: TabBarData[] = [
  {
    id: TabBarType.HOME_PAGE,
    title: $r('app.string.tab_home'),
    activeIcon: $r('app.media.ic_tab_home_check'),
    defaultIcon: $r('app.media.ic_tab_home')
  },{
    id: TabBarType.ORDER,
    title: $r('app.string.tab_order'),
    activeIcon: $r('app.media.ic_tab_order_check'),
    defaultIcon: $r('app.media.ic_tab_order')
  },
  {
    id: TabBarType.ORDER_LIST,
    title: $r('app.string.tab_order_list'),
    activeIcon: $r('app.media.ic_tab_list_check'),
    defaultIcon: $r('app.media.ic_tab_list')
  },
  {
    id: TabBarType.MINE,
    title: $r('app.string.tab_mine'),
    activeIcon: $r('app.media.ic_tab_mine_check'),
    defaultIcon: $r('app.media.ic_tab_mine')
  },
]

export interface HuaweiIDResp {
  openId: string
  unionId: string
  authCode: string
}