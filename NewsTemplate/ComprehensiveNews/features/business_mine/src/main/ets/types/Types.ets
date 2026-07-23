import { RouterMap } from 'lib_common';

/**
 * 我的GridItem类型
 */
export interface MineGridItem {
  icon: ResourceStr;
  label: ResourceStr;
  routerName: RouterMap;
}

/**
 * 消息菜单类型
 */
export enum MineMsgMenuType {
  Comment = 1,
  IM,
  Fan,
  System,
}

/**
 * 我的消息menuitem
 */
export interface IMineMsgMenuItem {
  type: MineMsgMenuType
  menuIcon: ResourceStr
  menuTitle: string
  routerName: RouterMap
}

@ObservedV2
export class MineMsgMenuItem implements IMineMsgMenuItem {
  @Trace type: MineMsgMenuType = MineMsgMenuType.System
  @Trace menuIcon: ResourceStr = ''
  @Trace menuTitle: string = ''
  @Trace routerName: RouterMap = RouterMap.INDEX_PAGE
  @Trace routerOnPop: () => void = () => {
  }
  @Trace latestNews: ResourceStr = ''
  @Trace allUnreadCount: number = 0
  @Trace receiveTime: number = 0

  constructor(v: IMineMsgMenuItem) {
    this.type = v.type;
    this.menuIcon = v.menuIcon;
    this.menuTitle = v.menuTitle;
    this.routerName = v.routerName;
  }
}