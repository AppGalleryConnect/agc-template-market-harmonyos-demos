export interface HotelTabBar {
  index: HotelTabBarType;
  title: ResourceStr;
}

export enum HotelTabBarType {
  INTRODUCTION = 0,
  SERVICE = 1,
  BOOKING = 2,
  SURROUNDING = 3
}

export const HOTEL_TABS_INFO: HotelTabBar[] = [
  {
    index: HotelTabBarType.INTRODUCTION,
    title: '门店介绍',
  },
  {
    index: HotelTabBarType.SERVICE,
    title: '设施与服务',
  },
  {
    index: HotelTabBarType.BOOKING,
    title: '预定须知',
  },
  {
    index: HotelTabBarType.SURROUNDING,
    title: '周边信息',
  },
];