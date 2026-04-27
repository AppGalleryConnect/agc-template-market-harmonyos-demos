import { PersistenceV2 } from '@kit.ArkUI';
import { LoginPageBuilder } from 'aggregated_login';
import { GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap, UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PersonInfoInputPageBuilder, PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodel/IndexVM';
import { HomePageBuilder } from './HomePage';

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  vm: IndexVM = new IndexVM();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

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
          this.gotoLoginOrMainPage();
        }
      })
      return;
    }

    this.gotoLoginOrMainPage();
  }

  gotoLoginOrMainPage() {
    if (this.userInfo.isLogin) {
      phoneRouterControl.replacePage({
        pageName: RouterMap.MAIN_PAGE,
        builder: wrapBuilder(HomePageBuilder)
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          this.gotoMineOrMainPage();
        }
      })
    }
  }

  gotoMineOrMainPage() {
    if (this.userInfo.isEditOk) {
      phoneRouterControl.replacePage({
        pageName: RouterMap.MAIN_PAGE,
        builder: wrapBuilder(HomePageBuilder)
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PERSONAL_INFO_INPUT_PAGE,
        builder: wrapBuilder(PersonInfoInputPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          phoneRouterControl.replacePage({
            pageName: RouterMap.MAIN_PAGE,
            builder: wrapBuilder(HomePageBuilder)
          })
        }
      })
    }
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