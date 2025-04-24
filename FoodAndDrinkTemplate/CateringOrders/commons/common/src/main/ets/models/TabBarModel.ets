export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  defaultIcon: ResourceStr;
}

export enum TabBarType {
  HOMEPAGE = 0,
  ORDER,
  MINE
}

export const TABS_INFO: TabBarData[] = [
  {
    id: TabBarType.HOMEPAGE,
    title: $r('app.string.tab_order'),
    activeIcon: $r('app.media.order_check_tab'),
    defaultIcon: $r('app.media.order_tab')
  },
  {
    id: TabBarType.ORDER,
    title: $r('app.string.tab_order_list'),
    activeIcon: $r('app.media.order_list_check_tab'),
    defaultIcon: $r('app.media.order_list_tab')
  },
  {
    id: TabBarType.MINE,
    title: $r('app.string.tab_mine'),
    activeIcon: $r('app.media.mine_check_tab'),
    defaultIcon: $r('app.media.mine_tab')
  },
]

export interface HuaweiIDResp {
  openId: string
  unionId: string
  authCode: string
}