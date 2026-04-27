import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();

  aboutToAppear(): void {
    this.vm.setInterception();
    this.vm.registerBreakpointListener(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.breakpoint?.unRegister();
  }

  build() {
    Navigation(this.vm.navStack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
  }
}