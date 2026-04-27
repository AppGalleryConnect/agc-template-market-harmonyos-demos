import { HomeBuilder } from 'home'
import { GuideBuilder } from 'guide'
import { MineBuilder } from 'mine'
import { TicketsBuilder } from 'ticket'
import { TabBarType } from 'types'

export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  defaultIcon: ResourceStr;
  component: WrappedBuilder<[]>
}

export const TABS_INFO: TabBarData[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.home_active'),
    defaultIcon: $r('app.media.home_default'),
    component: wrapBuilder(HomeBuilder),
  },
  {
    id: TabBarType.TICKET,
    title: '门票',
    activeIcon: $r('app.media.tickets_active'),
    defaultIcon: $r('app.media.tickets_default'),
    component: wrapBuilder(TicketsBuilder),
  },
  {
    id: TabBarType.GUIDE,
    title: '导览',
    activeIcon: $r('app.media.guide_active'),
    defaultIcon: $r('app.media.guide_default'),
    component: wrapBuilder(GuideBuilder),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.mine_active'),
    defaultIcon: $r('app.media.mine_default'),
    component: wrapBuilder(MineBuilder),
  },
]

export class RouterModule {
  public static stack: NavPathStack = new NavPathStack()
  //todo 支持华为应用内分享的页面
  static readonly SHARE_PAGES: string[] = [
    'PageDetail',
    'AttractionDetail',
    'CommodityDetail',
    'TicketDetail',
  ]

  public static setStack(stack: NavPathStack) {
    RouterModule.stack = stack
  }

  public static getStack(): NavPathStack {
    return RouterModule.stack;
  }
}