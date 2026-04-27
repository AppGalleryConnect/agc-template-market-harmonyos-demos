import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap, TempBarHeight, UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder, PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodels/IndexVM';
import { HomePageBuilder } from './HomePage';

@Entry
@ComponentV2
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  vm: IndexVM = new IndexVM();
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;

  @Builder
  pageStackMap(name: string, _param: string) {
    phoneRouterControl.getPageBuilder(name)?.builder(_param)
  }

  async aboutToAppear() {
    this.tempBarHeight.topValue = 0;

    phoneRouterControl.createRouter(this.pageStack)
    this.vm.registerBreakpointListener(this.getUIContext());
    this.vm.displayOrientationListener();
    this.vm.setRouterPage();
    await this.vm.initSdk(this.getUIContext().getHostContext());
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
      this.gotoMainPage();
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder),
        onPop: (_popInfo: PopInfo) => {
          this.gotoMainPage();
        }
      })
    }
  }

  gotoMainPage() {
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
      .padding({
        top: this.tempBarHeight.topValue,
        bottom: this.tempBarHeight.bottomValue
      })
    }
  }
}