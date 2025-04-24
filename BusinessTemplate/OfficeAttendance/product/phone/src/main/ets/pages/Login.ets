import { LoginView } from '@ohos_agcit/office_attendance_account'
import { MainEntryVM, RouterMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { router, window } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Login {
  vm: MainEntryVM = MainEntryVM.instance;

  // 在目标页面的生命周期中设置隐私模式
  onPageShow(): void {
    window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
      windowStage.setWindowPrivacyMode(true); // 开启隐私模式
    });
  }

  onPageHide(): void {
    window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
      windowStage.setWindowPrivacyMode(false); // 关闭隐私模式
    });
  }

  build() {
    Navigation(this.vm.navStack) {
      Row() {
        LoginView({
          'callback': () => {
            router.replaceUrl({url: 'pages/MainEntry'})
          }
        });
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Stack);
  }
}
