import { CommonConstants, CommonHeader, RouterModule, WindowUtil } from 'lib_foundation';
import { SettingView } from 'app_setting';
import { SettingVM } from '../viewmodels/SettingVM';

@ComponentV2
export struct SettingPage {
  @Local vm: SettingVM = new SettingVM();

  build() {
    NavDestination() {
      CommonHeader({ title: '设置' }).margin({ bottom: CommonConstants.SPACE_8 })

      Column() {
        SettingView({
          pathStack: RouterModule.stack,
          settingList: [this.vm.group1, this.vm.group2],
          isLogin: this.vm.userInfo.isLogin,
          signOutApi: () => this.vm.signOutApi(),
          signOutSuccessCb: () => this.vm.signOutSuccessCb(),
        })
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }
}


@Builder
export function settingPageBuilder() {
  SettingPage()
}