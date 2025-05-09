import { TabInfo } from 'common'
import { RouteDesignBuilder } from 'routedesign'
import { CloudCardBuilder } from 'codescan'
import { PersonalCenterBuilder } from 'personalcenter'
import {HomePageBuilder} from 'frontpage'
export const homeTabInfo: TabInfo[] = [
  {
    index: 0,
    label: $r('app.string.home_tab_label'),
    activeIcon: $r('app.media.home_active_icon'),
    defaultIcon: $r('app.media.home_default_icon'),
    component: wrapBuilder(HomePageBuilder)
  },
  {
    index: 1,
    label: $r('app.string.route_tab_label'),
    activeIcon: $r('app.media.route_active_icon'),
    defaultIcon: $r('app.media.route_default_icon'),
    component: wrapBuilder(RouteDesignBuilder)
  },
  {
    index: 2,
    label: $r('app.string.code_scan_label'),
    activeIcon:$r('app.media.code_active_icon'),
    defaultIcon: $r('app.media.code_default_icon'),
    component: wrapBuilder(CloudCardBuilder)
  },
  {
    index: 3,
    label: $r('app.string.personal_tab_label'),
    activeIcon: $r('app.media.personal_active_icon'),
    defaultIcon: $r('app.media.personal_default_icon'),
    component: wrapBuilder(PersonalCenterBuilder)
  }
]