import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingView } from 'module_app_setting';
import { SettingNetworkVM } from '../viewmodels/SettingNetworkVM';

@Builder
export function SettingNetworkBuilder() {
  SettingNetwork()
}

@ComponentV2
struct SettingNetwork {
  @Local vm: SettingNetworkVM = new SettingNetworkVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '播放与网络设置',
        })
        Column({ space: CommonConstants.SPACE_M }) {
          SettingView({
            pathStack: RouterUtils.getStack(),
            settingList: [this.vm.group1, this.vm.group2],
            fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            pagePadding: {
              top: 0,
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