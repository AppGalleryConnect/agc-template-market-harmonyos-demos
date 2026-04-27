import { LanguagePickerPage } from 'choose_language';
import { phoneRouterControl } from 'oh_router';
import { RouterMap, UserInfo } from 'common';
import { VipCenterPageBuilder, LoginPageBuilder, LoginRedirectFlag } from 'person';
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel';
import { PersistenceV2, AppStorageV2 } from '@kit.ArkUI';

/**
 * @usage: 翻译语言选择弹窗组件，封装LanguagePickerPage提供语言选择功能。支持VIP语言升级引导和登录状态检查。
 * 主要数据结构包括TranslateHomeViewModel（首页视图模型）、UserInfo（用户信息）。
 * 包含Monitor监听VIP状态变化同步更新。
 * @layout: 组件为空Column容器，通过bindSheet绑定LanguagePickerPage弹窗。弹窗高度95%，支持拖拽关闭。
 * @constraints: VIP语言升级需要先登录
 * @domain: 翻译工具
 * @isGen: true
 * @zhName: 翻译语言选择弹窗组件
 * @fileType: component
 * @subPage: VipCenterPage,LoginPage
 * @component: LanguagePickerPage
 * @image: screenshot/home/TranslateLanguagePickerSheet.jpg
 */
@ComponentV2
export struct TranslateLanguagePickerSheet {
  @Param vm: TranslateHomeViewModel = TranslateHomeViewModel.instance;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('userInfo.isVip')
  onVipStatusChange(): void {
    this.vm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }


  @Builder
  LanguagePickerSheetBuilder() {
    LanguagePickerPage({
      viewModel: this.vm.languageViewModel,
      onClose: () => {
        this.vm.closeLanguagePicker();
      },
      onVipUpgrade: () => {
        // 先关闭Sheet
        this.vm.closeLanguagePicker();

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
            });
          } else {
            // 已登录，跳转到VIP中心
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            });
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
          this.vm.closeLanguagePicker();
        }
      })
  }
}
