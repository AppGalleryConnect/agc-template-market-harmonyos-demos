import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { BarVM } from 'common';
import { GenericCard } from '../comp/GenericCard';

/**
 * @usage: 用于展示应用设置页面。包含个人信息、隐私设置、清除缓存、关于我们等功能选项。
 * 关键数据结构：vm（SettingAboutVM视图模型，包含用户信息和缓存大小等数据）。
 * 根据用户登录状态控制个人信息入口的可访问性。
 * @layout: 页面采用垂直布局（Column）。顶部为CommonHeader导航栏（标题居中，返回按钮左对齐），
 * 下方为设置选项列表（垂直排列的UserInfoRow组件，每项左对齐显示功能名称，右对齐显示箭头或内容）。
 * 选项之间使用分割线分隔。
 * @constraints: 个人信息功能需要用户登录后才可访问。清除缓存功能会显示当前缓存大小。
 * 页面跳转依赖RouterMap中定义的路由路径。
 * @zhName: 设置页面
 * @fileType: page
 * @isGen: true
 * @subPage: EditPersonalCenter, PrivacySettingsPage, AboutPage
 * @component: CommonHeader, UserInfoRow, GenericCard
 * @image: screenshots/person/Setup.png
 */
@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();

  aboutToAppear(): void {
    this.vm.init()
  }

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
      pageBackgroundColor: $r('sys.color.comp_background_gray'),
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
                  this.getUIContext().getPromptAction().showToast({ message: '请先登录' });
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
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
