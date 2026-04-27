export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  defaultIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  DISCOVER = 1,
  MAP = 2,
  SHOP = 3,
  MINE = 4
}

export const tabsInfo: TabBarData[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.home_active'),
    defaultIcon: $r('app.media.home')
  },
  {
    id: TabBarType.DISCOVER,
    title: '发现',
    activeIcon: $r('app.media.find_active'),
    defaultIcon: $r('app.media.find')
  },
  {
    id: TabBarType.MAP,
    title: '地图',
    activeIcon: $r('app.media.map_active'),
    defaultIcon: $r('app.media.map')
  },
  {
    id: TabBarType.SHOP,
    title: '商城',
    activeIcon: $r('app.media.shop_active'),
    defaultIcon: $r('app.media.shop')
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.mine_active'),
    defaultIcon: $r('app.media.mine')
  }
]