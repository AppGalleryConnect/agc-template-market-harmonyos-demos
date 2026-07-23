import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingView } from 'module_app_setting';
import { SettingViewModel } from '../viewmodels/SettingVM';

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
struct SettingPage {
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '设置',
        })
        Column({ space: CommonConstants.SPACE_M }) {
          SettingView({
            pathStack: RouterUtils.getStack(),
            settingList: [this.vm.group1, this.vm.group2, this.vm.group3, this.vm.group4],
            isLogin: this.vm.userInfoModel.isLogin,
            signOutApi: () => this.vm.signOutApi(),
            signOutSuccessCb: () => this.vm.signOutSuccessCb(),
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            pagePadding: {
              bottom: this.vm.windowModel.windowBottomPadding,
            },
          })
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}