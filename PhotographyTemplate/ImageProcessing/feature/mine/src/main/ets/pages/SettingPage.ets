import {
  AboutModel,
  SettingItem,
  SettingType,
  SettingView,
  SupportedSetting,
} from 'app_setting';
import {
  BaseTitle,
  CommonConstants,
  HttpApi,
  RouterMap,
  RouterModule,
  UIDialogUtil,
} from 'commonlib';
import { SettingPageVM } from '../viewmodels/SettingPageVM';


@Builder
export function SettingPageBuilder() {
  SettingPage();
}

@ComponentV2
export struct SettingPage {
  vm: SettingPageVM = new SettingPageVM();

  aboutToAppear(): void {
    this.vm.init();
  }

  // 退出登录
  openLogoutDialog() {
    UIDialogUtil.open({ content: '是否确认退出登录？' }, () => {
      HttpApi.userLogout(this.vm.userInfo.phone).then(() => {
        this.vm.userInfo.isLogin = false;
        RouterModule.pop();
      })
    })
  }

  build() {
    NavDestination() {
      Row() {
        BaseTitle({
          title: '设置',
          titleFontSize: $r('sys.float.Title_S'),
          showBackBtn: true,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
      })

      Scroll() {
        Column() {
          SettingView({
            pathStack: RouterModule.stack,
            settingList: [this.vm.group1, this.vm.group2, this.vm.group3],
          })
            .layoutWeight(1)
          if (this.vm.userInfo.isLogin) {
            Row() {
              Button('退出登录')
                .width('100%')
                .constraintSize({ maxWidth: 360 })
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.openLogoutDialog();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ left: 28, right: 28 })
          }
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .padding({
        bottom: this.vm.windowSize.bottomHeight + 12,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}