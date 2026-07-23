import { AppConstants, RouterUtils } from 'lib_common'
import { SearchControllerMng } from 'lib_search';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();

  aboutToAppear(): void {
    this.vm.contextModel.setUIContext('phone', this.getUIContext());
    this.vm.setInterception();
    this.vm.redirect();
    this.vm.navDestinationListener()
    this.vm.windowStageEventListener()
    this.vm.registerBreakpointListener(this.getUIContext());
    this.vm.displayOrientationListener()
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
    SearchControllerMng.destroy();
  }

  build() {
    Navigation(RouterUtils.getStack()) {
    }
    .id(AppConstants.NAVIGATION_ID)
    .hideNavBar(true)
    .enabled(this.vm.isEnabled)
    .hideTitleBar(true)
    .onTouch(() => {
      SearchControllerMng.closeAllPop();
    })
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.vm.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.vm.isEnabled = true;
        },
      });
    })
  }
}