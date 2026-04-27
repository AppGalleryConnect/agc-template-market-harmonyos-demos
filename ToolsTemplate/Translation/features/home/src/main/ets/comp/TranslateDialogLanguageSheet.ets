import { LanguagePickerPage } from 'choose_language'
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { RouterMap, UserInfo } from 'common'
import { LoginPageBuilder, LoginRedirectFlag, VipCenterPageBuilder } from 'person'
import { phoneRouterControl } from 'oh_router'

//翻译对话页面的语言选择Sheet
@ComponentV2
export struct TranslateDialogLanguageSheet {
  @Param vm: TranslateHomeViewModel = TranslateHomeViewModel.instance
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Builder
  LanguagePickerSheetBuilder() {
    LanguagePickerPage({
      viewModel: this.vm.languageViewModel,
      onClose: () => {
        this.vm.closeLanguagePicker()
      },
      onVipUpgrade: () => {
        this.vm.closeLanguagePicker()

        // 延迟执行,确保Sheet完全关闭后再跳转
        setTimeout(() => {
          // 检查登录状态
          if (!this.userInfo.isLogin) {
            // 设置全局标志,登录后跳转到VIP中心
            const flag = AppStorageV2.connect(LoginRedirectFlag, () => new LoginRedirectFlag())!;
            flag.redirectToVip = true;
            // 跳转到登录页
            phoneRouterControl.jumpPage({
              pageName: RouterMap.LOGIN_PAGE,
              builder: wrapBuilder(LoginPageBuilder)
            })
          } else {
            // 已登录，跳转到VIP中心
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
          }
        }, 100);
      }
    })
  }

  build() {
    Column()
      .width(0)
      .height(0)
      .bindSheet($$this.vm.showLanguagePicker, this.LanguagePickerSheetBuilder(), {
        height: '95%',
        showClose: false,
        dragBar: true,
        backgroundColor: Color.White,
        onAppear: () => {
          // Sheet打开时同步VIP状态
          this.vm.languageViewModel.setVipStatus(this.userInfo.isVip);
        },
        onDisappear: () => {
          this.vm.closeLanguagePicker()
        }
      })
  }
}
