import { buildTitleBar, CommonConstants, RouterModule } from 'commonlib';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { SettingsPageVM } from '../viewModels/SettingsPageVM';
import { FunctionItem } from '../types/Index';
import { SettingView } from 'app_setting';

@Builder
export function SettingsPageBuilder() {
  SettingsPage();
}

@ComponentV2
struct SettingsPage {
  vm: SettingsPageVM = new SettingsPageVM();

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          SettingView({
            pathStack: RouterModule.getStack(),
            isLogin: true,
            settingList: [this.vm.group1, this.vm.group6, this.vm.group2, this.vm.group3, this.vm.group4,
              this.vm.group5],
            signOutApi: () => this.vm.logout(),
          })
        }
        .width('100%')
      }
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .title(buildTitleBar('设置'), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: 40 })
  }
}

