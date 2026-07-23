export class Constants {
  public static readonly USER_ICON_W: number = 48;
  public static readonly SMALL_USER_ICON_W: number = 24;
  public static readonly MEDIUM_ICON_W: number = 48;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
  public static readonly LIKE_SHOW_W: number = 156;
}

export interface TabItem {
  id: number
  label: string
}

export enum TabEnum {
  Article = 0,
  Video,
  Post,
}

export const TAB_LIST: TabItem[] = [
  {
    id: TabEnum.Article,
    label: '文章',
  },
  {
    id: TabEnum.Video,
    label: '视频',
  },
  {
    id: TabEnum.Post,
    label: '动态',
  },
];
