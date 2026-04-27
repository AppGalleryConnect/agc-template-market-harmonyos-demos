import { GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodels/IndexVM';
import { HomePageBuilder } from './HomePage';

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  vm: IndexVM = new IndexVM();

  @Builder
  pageStackMap(name: string, _param: string) {
    phoneRouterControl.getPageBuilder(name)?.builder(_param)
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
        onPop: (_popInfo: PopInfo) => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.MAIN_PAGE,
            builder: wrapBuilder(HomePageBuilder)
          })
        }
      })
      return;
    }
    phoneRouterControl.jumpPage({
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
    }
  }
}