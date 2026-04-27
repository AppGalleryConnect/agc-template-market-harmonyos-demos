import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { promptAction } from '@kit.ArkUI';
import { GenericCard } from '../comp/GenericCard';

/**
 * @usage: 用于展示应用设置页面，包含个人信息、隐私设置、版本检测、关于我们和退出登录功能入口。关键参数：
 * vm.userInfo.isLogin登录状态。包含if逻辑：当用户已登录时显示退出登录按钮。
 * @layout: 页面整体采用垂直布局（Column）。顶部为CommonHeader导航栏，中间为两个GenericCard卡片，
 * 每个卡片包含多个UserInfoRow设置项（纵向排列，左对齐），底部为退出登录按钮（居中对齐）。
 * @zhName: 设置页面
 * @fileType: page
 * @isGen: true
 * @domain: 视频
 * @image: screenshot/person/setting.jpg
 * @subPage: EditPersonalCenterPage, PrivacySettingsPage, AboutPage
 * @component: CommonHeader, UserInfoRow, GenericCard, OHPage
 */
@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
      pageBackgroundColor: $r('sys.color.comp_background_gray')
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '设置',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      Column() {
        Column() {
          GenericCard() {
            UserInfoRow({
              leftTitle: '个人信息', rightOnClick: () => {
                if (this.vm.userInfo.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.PERSONAL_CENTER_PAGE,
                    builder: wrapBuilder(EditPersonalCenterBuilder)
                  })
                } else {
                  promptAction.showToast({ message: '请先登录' });
                }
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

          GenericCard() {
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
        }
        .height(388)
        .width('100%')


        Button('退出登录')
          .borderRadius(20)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(500)
          .width('100%')
          .height(40)
          .onClick(() => {
            if (this.vm.userInfo.isLogin) {
              this.vm.clearUserInfo()
              this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
              phoneRouterControl.popPage()
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
            }
          })
          .visibility(this.vm.userInfo?.isLogin ? Visibility.Visible : Visibility.Hidden)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
