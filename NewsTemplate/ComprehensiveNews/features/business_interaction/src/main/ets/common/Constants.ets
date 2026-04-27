export class Constants {
  static userIconW: number = 40;
  static largeIconW: number = 48;
}

export interface TabItem {
  id: number
  label: string
}

export enum TabEnum {
  Watch = 0,
  Recommend,
  Nearby,
  Topic,
}

export const TAB_LIST: TabItem[] = [
  {
    id: TabEnum.Watch,
    label: '关注',
  },
  {
    id: TabEnum.Recommend,
    label: '推荐',
  },
  {
    id: TabEnum.Nearby,
    label: '附近',
  },
];
