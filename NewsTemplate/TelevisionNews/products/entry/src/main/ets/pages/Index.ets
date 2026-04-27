import { AppConstants, Constants, RouterUtils } from 'lib_common';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { IndexVM } from '../viewmodel/IndexVM';

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM(this.getUIContext());

  aboutToAppear() {
    this.vm.contextModel.setUIContext('phone', this.getUIContext());
    this.vm.redirect()
    this.vm.registerBreakpointListener(this.getUIContext());
    this.vm.windowStageEventListener()
    this.vm.displayOrientationListener()
  }

  aboutToDisappear(): void {
    this.vm.unSubscribeOff()
  }

  build() {
    Column() {
      Navigation(RouterUtils.getStack()) {
      }
      .id(AppConstants.NAVIGATION_ID)
      .hideTitleBar(true)
      .hideNavBar(true)
      .enabled(this.vm.isEnabled)
      .mode(NavigationMode.Stack)
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE)
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
    .height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE);

  }
}
