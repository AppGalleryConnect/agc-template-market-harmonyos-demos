import { CommonHeader, RouterMap, BarVM, OHDialog, OHDialogModel } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { LoginPageBuilder } from 'aggregated_login';
import { ClearCacheDialogModel } from '../viewmodel/ClearCacheDialogModel';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { LogoutDialogModel } from '../viewmodel/LogoutDialogModel';
import { SetUpGenericCard } from '../comp/SetUpGenericCard';

/**
 * @usage: 设置页面，提供应用设置和用户管理功能。包含个人信息管理、隐私设置、缓存清理、版本检查、关于我们、退出登录功能。
 主要数据结构包括UserInfo（用户信息）、设置项配置。包含缓存计算、版本检查、退出登录等逻辑。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为设置项列表。设置项使用UserInfoRow组件展示，
 支持文本显示、开关切换、点击跳转等交互。
 * @constraints: 退出登录按钮和逻辑不可删除
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页面
 * @subPage: EditPersonalCenter,PrivacySettingsPage,AboutPage
 * @component: CommonHeader,UserInfoRow,ClearCacheDialog，LogoutDialog，SetUpGenericCard，OHPage
 * @image: screenshot/person/Setup.jpg
 */
@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();

  aboutToAppear(): void {
    this.vm.init()
    this.vm.getClearSize()
  }

  @Builder
  line() {
    Divider()
      .strokeWidth('1px')
      .width('100%')
      .color($r('sys.color.comp_divider'))
      .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }

  @Builder
  clearCacheDialogBuilder(vm: OHDialogModel) {
    Text(vm.subtitle + vm.cacheSize)
      .fontSize($r('sys.float.Body_M'))
      .fontColor(Color.Black)
      .lineHeight($r('app.float.vp_22'))
      .maxLines(-1)

    Blank().height($r('app.float.vp_26'))
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.person_setting_title'),
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
        leftImageRes: $r('app.media.ic_backward2')
      })

      Scroll() {
        Column() {
          SetUpGenericCard() {
            UserInfoRow({
              leftTitle: '个人信息', rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.PERSONAL_CENTER_PAGE,
                  builder: wrapBuilder(EditPersonalCenterBuilder)
                })
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: '隐私设置', rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.PRIVACY_SETTINGS_PAGE,
                  builder: wrapBuilder(PrivacySettingsPageBuilder)
                })
              }
            })
          }

          SetUpGenericCard() {
            UserInfoRow({
              leftTitle: '清除缓存', rightContent: this.vm.cacheSize, rightOnClick: () => {
                let clearCacheDialogModelVM = new ClearCacheDialogModel();
                clearCacheDialogModelVM.cacheSize = this.vm.cacheSize;
                clearCacheDialogModelVM.onValueConfirmClick = () => {
                  this.vm.clean();
                }
                clearCacheDialogModelVM.childBuilder = this.clearCacheDialogBuilder
                OHDialog.ShowPopup(clearCacheDialogModelVM)
              }
            })
          }

          SetUpGenericCard() {
            UserInfoRow({
              leftTitle: '版本检测', rightOnClick: () => {
                this.vm.checkAppUpdate()
              }
            })

            this.line()
            UserInfoRow({
              leftTitle: '关于我们', rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.ABOUT_PAGE,
                  builder: wrapBuilder(AboutPageBuilder)
                })
              }
            })
          }

          Blank().layoutWeight(1)
          Button($r('app.string.person_setting_logout'))
            .borderRadius($r('sys.float.corner_radius_level10'))
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .height($r('app.float.vp_40'))
            .onClick(() => {
              if (this.vm.userInfo.isLogin) {
                let logoutDialogModelVM = new LogoutDialogModel();
                logoutDialogModelVM.onValueConfirmClick = () => {
                  this.vm.userInfo.isLogin = false;
                  this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: $r('app.string.person_setting_logout_success'), duration: 2000 });
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                    builder: wrapBuilder(LoginPageBuilder),
                    onPop: (_popInfo: PopInfo) => {
                      let mainBuilder = phoneRouterControl.getPageBuilder(RouterMap.MAIN_PAGE);
                      phoneRouterControl.replacePage({
                        pageName: RouterMap.MAIN_PAGE,
                        builder: mainBuilder
                      });
                    }
                  })
                }
                OHDialog.ShowPopup(logoutDialogModelVM)
              } else {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: $r('app.string.person_setting_not_login'), duration: 2000 });
              }
            })
        }
        .width('100%')
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({
      bottom: BarVM.instance.aiBarH
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
