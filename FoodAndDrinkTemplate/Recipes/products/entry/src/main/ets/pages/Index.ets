import {
  BreakpointUtils,
  CommentUtil,
  CommonConstants,
  GlobalContextUtils,
  PreferenceUtil,
  RouterMap,
  RouterModule
} from 'commonlib';
import { LoneTakeAnimationsTransition } from 'module_transition';

@Entry
@ComponentV2
struct Index {
  navStack: NavPathStack = RouterModule.getStack();
  breakpoint: BreakpointUtils | null = null;
  @Local isEnabled: boolean = true;

  handleDark() {
    try {
      let colorMode = Number(PreferenceUtil.getInstance().get(CommonConstants.LIGHT_DARK_KEY, 1))
      this.getUIContext()?.getHostContext()?.getApplicationContext()
        .setColorMode(colorMode);
      PreferenceUtil.getInstance().put(CommonConstants.LIGHT_DARK_KEY, colorMode ?? 1)
    } catch (e) {
    }
  }

  aboutToAppear(): void {
    GlobalContextUtils.setUIContext('entry', this.getUIContext());
    CommentUtil.setForegroundFlag();
    this.handleDark();
    this.breakpoint = new BreakpointUtils(this.getUIContext().getMediaQuery());
    this.breakpoint?.register()
    RouterModule.replace(RouterMap.LAUNCH_PAGE)
  }

  aboutToDisappear(): void {
    this.breakpoint?.unRegister();
  }

  build() {
    Navigation(this.navStack) {
    }
    .enabled(this.isEnabled)
    .id('navigationId')
    .hideTitleBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        }
      });
    })
  }
}
