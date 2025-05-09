import { AppRouter, BaseTabBarItem } from 'common';


@ObservedV2
export class HomePageVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = AppRouter.navStack;
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  // 单程和往返的tab数据
  public tabBarList: BaseTabBarItem[] = [
    new BaseTabBarItem('ONE_WAY', $r('app.string.one_way_label')),
    new BaseTabBarItem('ROUND_TRIP', $r('app.string.round_trip_label')),
  ];
}