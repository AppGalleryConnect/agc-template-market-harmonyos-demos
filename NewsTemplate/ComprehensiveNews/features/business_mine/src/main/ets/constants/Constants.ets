import { RouterMap } from 'lib_common';
import { IMineMsgMenuItem, MineGridItem, MineMsgMenuType } from '../types/Types';

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.ic_grid_comment'),
    label: '评论',
    routerName: RouterMap.MINE_COMMENT_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_message'),
    label: '消息',
    routerName: RouterMap.MINE_MESSAGE_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_star'),
    label: '收藏',
    routerName: RouterMap.MINE_MARK_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_like'),
    label: '点赞',
    routerName: RouterMap.MINE_LIKE_PAGE,
  },
];

export const messageMenuList: IMineMsgMenuItem[] = [
  {
    type: MineMsgMenuType.Comment,
    menuIcon: $r('app.media.ic_message_comment'),
    menuTitle: '评论与回复',
    routerName: RouterMap.MINE_MSG_COMMENT,
  },
  {
    type: MineMsgMenuType.IM,
    menuIcon: $r('app.media.ic_message_im'),
    menuTitle: '私信',
    routerName: RouterMap.MINE_MSG_IM,
  },
  {
    type: MineMsgMenuType.Fan,
    menuIcon: $r('app.media.ic_message_fans'),
    menuTitle: '新增粉丝',
    routerName: RouterMap.MINE_MSG_FANS,
  },
  {
    type: MineMsgMenuType.System,
    menuIcon: $r('app.media.ic_message_system'),
    menuTitle: '系统消息',
    routerName: RouterMap.MINE_MSG_SYSTEM,
  },
];

/**
 * 离线WebID映射表
 */
export enum WebIdMap {
  ChatWebId = 'webId1',
}

export class Constants {
  public static readonly NEWS_IMAGE_WIDTH: number = 96;
  public static readonly NEWS_IMAGE_HEIGHT: number = 72;
  public static readonly NORMAL_BTN_H: number = 40;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
}
