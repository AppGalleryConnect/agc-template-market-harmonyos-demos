import { WidgetUtil } from 'business_home';
import { GlobalContextUtils, RouterModule } from 'lib_foundation';
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: IndexVM = new IndexVM();

  aboutToAppear(): void {
    AppStorage.setOrCreate('uiContext', this.getUIContext())
    GlobalContextUtils.setUIContext('phone', this.getUIContext());
    // 拦截
    this.vm.checkSafeAgreed();
    // 初始化
    this.vm.init();
    this.vm.registerBreakpoint(this.getUIContext().getMediaQuery());
    // 订阅卡片增删
    WidgetUtil.subscribeFormId(this.getUIContext().getHostContext()!);
  }

  aboutToDisappear(): void {
    this.vm.unRegisterBreakpoint();
  }

  build() {
    Navigation(RouterModule.stack) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
  }
}
