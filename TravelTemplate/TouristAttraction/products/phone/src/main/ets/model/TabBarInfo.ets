import { HomeBuilder } from 'home'
import { GuideBuilder } from 'guide'
import { MineBuilder } from 'mine'
import { OrderBuilder } from 'order'
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
    component: wrapBuilder(HomeBuilder)
  },
  {
    id: TabBarType.TICKET,
    title: '门票',
    activeIcon: $r('app.media.tickets_active'),
    defaultIcon: $r('app.media.tickets_default'),
    component: wrapBuilder(TicketsBuilder)
  },
  {
    id: TabBarType.GUIDE,
    title: '导览',
    activeIcon: $r('app.media.guide_active'),
    defaultIcon: $r('app.media.guide_default'),
    component: wrapBuilder(GuideBuilder)
  },
  {
    id: TabBarType.ORDER,
    title: '订单',
    activeIcon: $r('app.media.order_active'),
    defaultIcon: $r('app.media.order_default'),
    component: wrapBuilder(OrderBuilder)
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.mine_active'),
    defaultIcon: $r('app.media.mine_default'),
    component: wrapBuilder(MineBuilder)
  }
]