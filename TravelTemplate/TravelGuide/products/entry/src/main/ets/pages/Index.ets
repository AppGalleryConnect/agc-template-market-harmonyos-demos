import { GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodels/IndexVM';
import { HomePageBuilder } from './HomePage';
import {
  RouteCitySelectPageBuilder,
  RouteListPageBuilder,
  RouteDetailPageBuilder,
  RouteListParams,
  RouteDetailParams
} from 'travel_planning';

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  vm: IndexVM = new IndexVM();

  @Builder
  routeCitySelectBuilder(param: string) {
    RouteCitySelectPageBuilder(param)
  }

  @Builder
  routeListBuilder(param: RouteListParams) {
    RouteListPageBuilder(param)
  }

  // 辅助函数：解析参数字符串为 RouteListParams
  private parseRouteListParams(paramStr: string): RouteListParams {
    try {
      return JSON.parse(paramStr || '{}') as RouteListParams
    } catch {
      return { city: '', days: 0 }
    }
  }

  // 辅助函数：解析参数字符串为 RouteDetailParams
  private parseRouteDetailParams(paramStr: string): RouteDetailParams {
    try {
      return JSON.parse(paramStr || '{}') as RouteDetailParams
    } catch {
      return { route: { id: '', title: '', days: 0, locations: 0, attractions: [], coverImage: $r('app.media.ic_route_planning_bg'), city: '' } }
    }
  }

  @Builder
  routeListBuilderFromString(paramStr: string) {
    RouteListPageBuilder(this.parseRouteListParams(paramStr))
  }

  @Builder
  routeDetailBuilderFromString(paramStr: string) {
    RouteDetailPageBuilder(this.parseRouteDetailParams(paramStr))
  }

  @Builder
  pageStackMap(name: string, _param: string) {
    if (name === 'RouteCitySelectPage') {
      this.routeCitySelectBuilder(_param)
    } else if (name === 'RouteListPage') {
      this.routeListBuilderFromString(_param)
    } else if (name === 'RouteDetailPage') {
      this.routeDetailBuilderFromString(_param)
    } else {
      phoneRouterControl.getPageBuilder(name)?.builder(_param)
    }
  }

  aboutToAppear() {
    phoneRouterControl.createRouter(this.pageStack)
    this.vm.registerBreakpointListener(this.getUIContext());
    this.vm.displayOrientationListener();
    //读取状态值，如果为空设置为true
    let isFirstLaunch = PreferenceUtil.getInstance(GlobalContext.getUIAbilityContext())
      .get(PreferenceConstant.FIRST_LAUNCH, true) as boolean
    if (isFirstLaunch) {
      //隐私政策
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PRIVACY_AGREEMENT_PAGE,
        builder: wrapBuilder(PrivacyAgreementPageBuilder),
        onPop: (popInfo: PopInfo) => {
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: wrapBuilder(HomePageBuilder)
          })
        }
      })
      return;
    }
    phoneRouterControl.replacePage({
      pageName: RouterMap.MAIN_PAGE,
      builder: wrapBuilder(HomePageBuilder)
    })
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
      }
      .hideNavBar(true)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageStackMap)
      .id(phoneRouterControl.defaultRouteName)
      .backgroundColor('#F3F4F5')
    }
  }
}