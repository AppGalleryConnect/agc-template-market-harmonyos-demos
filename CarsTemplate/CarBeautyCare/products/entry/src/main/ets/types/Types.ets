export interface TabListItem {
  label: string | Resource;
  icon: Resource;
  iconChecked: Resource;
}

export interface ServiceEntryItem {
  label: string | Resource;
  icon: Resource;
  tabIndex: number;
}

export interface SwiperBanner {
  imgUrl: Resource;
  href: string;
}

export interface MineServiceItem {
  label: Resource;
  icon: Resource;
  routePath: string;
}