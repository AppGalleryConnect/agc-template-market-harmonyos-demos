import { AppRouter } from 'common';
import { flightPageBuilder } from 'flight';
import { homePageBuilder } from 'home';
import { itineraryPageBuilder } from 'itinerary';
import { minePageBuilder } from 'mine';
import { TabInfo } from '../types';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = AppRouter.navStack;
  // 底部tab页签列表
  public tabInfos: TabInfo[] = [
    {
      label: $r('app.string.tab_home'),
      activeIcon: $r('app.media.ic_home_on'),
      defaultIcon: $r('app.media.ic_home_off'),
      component: wrapBuilder(homePageBuilder),
      safeAreaEdge: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM],
      pageBgColor: $r('sys.color.gray_01')
    },
    {
      label: $r('app.string.tab_itinerary'),
      activeIcon: $r('app.media.ic_trip_on'),
      defaultIcon: $r('app.media.ic_trip_off'),
      component: wrapBuilder(itineraryPageBuilder),
      safeAreaEdge: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM],
      pageBgColor: $r('sys.color.white')
    },
    {
      label: $r('app.string.tab_flight'),
      activeIcon: $r('app.media.ic_flight_on'),
      defaultIcon: $r('app.media.ic_flight_off'),
      component: wrapBuilder(flightPageBuilder),
      safeAreaEdge: [SafeAreaEdge.TOP],
      pageBgColor: $r('sys.color.gray_01')
    },
    {
      label: $r('app.string.tab_mine'),
      activeIcon: $r('app.media.ic_mine_on'),
      defaultIcon: $r('app.media.ic_mine_off'),
      component: wrapBuilder(minePageBuilder),
      safeAreaEdge: [SafeAreaEdge.TOP],
      pageBgColor: $r('sys.color.gray_01')
    },
  ];
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

}
