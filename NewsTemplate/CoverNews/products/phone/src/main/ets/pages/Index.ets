import { AppConstants, BreakpointUtils, RouterUtils } from 'lib_common';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  private vm: IndexVM = new IndexVM();

  aboutToAppear() {
    this.vm.contextModel.setUIContext('phone', this.getUIContext());
    this.vm.redirect();
    this.vm.silentLogin();
    this.vm.privacyImpl.subscribe();
    this.vm.breakpoint = new BreakpointUtils(this.getUIContext().getMediaQuery());
    this.vm.breakpoint.register();
  }

  aboutToDisappear(): void {
    this.vm.privacyImpl.unSubscribe();
    this.vm.breakpoint?.unRegister();
  }

  build() {
    Navigation(RouterUtils.getStack()) {
    }
    .id(AppConstants.NAVIGATION_ID)
    .hideNavBar(true)
    .hideTitleBar(true)
  }
}