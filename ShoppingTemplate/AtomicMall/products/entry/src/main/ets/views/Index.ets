import { common } from '@kit.AbilityKit';
import { AccountUtils } from 'atomicservice_login';
import {
  AppPrivacyUtil,
  BreakpointSystem,
  iData,
  RouterMap,
  routerStack,
  WindowUtil
} from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  isEnabled: boolean = true
  @Local
  privacyImpl: AppPrivacyUtil = AppPrivacyUtil.instance;

  aboutToAppear(): void {
    this.privacyImpl.subscribe();
    if (!this.privacyImpl.CONFIG_SHOW_HOME && !this.privacyImpl.agreeFlag) {
      // 未同意隐私协议，不进入首页
      return;
    }
    this.signIn();
  }

  aboutToDisappear(): void {
    this.privacyImpl.unSubscribe();
  }

  @Monitor('privacyImpl')
  agreeFlagChange() {
    if (!this.privacyImpl.CONFIG_SHOW_HOME && this.privacyImpl.agreeFlag) {
      this.signIn()
    }
  }

  build() {
    Navigation(this.stack) {
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .hideBackButton(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        },
      });
    })
  }

  signIn() {
    AccountUtils.silentLogin((data) => {
      iData.global.userInfo.openId = data?.openID;
      iData.global.userInfo.authCode = data?.authorizationCode;
    })
    const uiContext = this.getUIContext()
    const abilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    const abilityName: string = abilityContext.abilityInfo.name;
    BreakpointSystem.register(uiContext)
    WindowUtil.setUIContext(abilityName, uiContext)
    routerStack.registerStack(abilityName, this.stack, uiContext)
    this.stack.pushPath({
      name: RouterMap.MAIN_ENTRY,
    }, false)
  }
}