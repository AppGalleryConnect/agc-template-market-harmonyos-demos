import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingView } from 'module_app_setting';
import { SettingPrivacyVM } from '../viewmodels/SettingPrivacyVM'

@Builder
export function SettingPrivacyBuilder() {
  SettingPrivacy()
}

@ComponentV2
struct SettingPrivacy {
  @Local vm: SettingPrivacyVM = new SettingPrivacyVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '隐私设置',
        })
        Column({ space: CommonConstants.SPACE_M }) {
          SettingView({
            pathStack: RouterUtils.getStack(),
            settingList: [this.vm.group1, this.vm.group2, this.vm.group3],
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
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