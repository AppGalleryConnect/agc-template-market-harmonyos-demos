export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  icon: Resource;
  activeIcon?:Resource;
}

export enum TabBarType {
  HOMEPAGE = 0,
  MINE
}

export const TABS_INFO: TabBarData[] = [
  {
    id: TabBarType.HOMEPAGE,
    title: '电视',
    icon: $r('app.media.ic_tab_home'),
    activeIcon: $r('app.media.ic_tab_home_active'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    icon: $r('app.media.ic_tab_person'),
    activeIcon: $r('app.media.ic_tab_person_active'),
  },
]

export interface HuaweiIDResp {
  openId: string
  unionId: string
  authCode: string
}