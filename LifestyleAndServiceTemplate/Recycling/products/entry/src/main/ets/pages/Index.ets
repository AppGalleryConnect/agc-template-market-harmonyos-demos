import { BarVM, GlobalContext, PreferenceConstant, PreferenceUtil, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PrivacyAgreementPageBuilder } from 'person';
import { IndexVM } from '../viewmodels/IndexVM';
import { HomePageBuilder } from './HomePage';

/**
 * @usage: 应用入口页面，负责初始化路由、注册断点监听、处理首次启动隐私协议展示。如果是首次启动，会先展示隐私协议页面，用户同意后跳转到主页；如果
 * 不是首次启动，直接跳转到主页。
 * @layout: 页面采用 Navigation 组件作为根容器，使用 NavPathStack 管理页面栈，通过 navDestination 配置页面路由映射。
 * @constraints: 此文件为应用入口，不建议修改核心逻辑。可根据需求调整首次启动逻辑、隐私协议展示方式等。
 * @isGen: false
 * @fileType: page
 * @zhName: 应用入口页面
 * @subPage: HomePage,PrivacyAgreementPage
 */

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
      // .backgroundColor('#F3F4F5')
      // .padding({
      //   bottom: BarVM.instance.aiBarH
      // })
    }
  }
}