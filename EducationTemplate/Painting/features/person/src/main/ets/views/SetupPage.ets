import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';

/**
 * @usage: 设置页面，提供清除缓存、隐私设置、版本检测、关于我们等应用设置功能，以及退出登录操作（仅登录用户可见）。
 * @layout: 页面采用垂直布局（Column），顶部为标题栏（CommonHeader），中间为可滚动区域（Scroll + Column），包含设置选项卡片
 * （GenericCard 嵌套，每个 UserInfoRow 横向排列，Divider 分隔），底部为退出登录按钮（Button，条件显示）。
 * @constraints: vm.cacheSize 用于显示缓存大小，不可删除。userInfo.isLogin 判断退出登录按钮显隐，逻辑不可修改。
 * 设置选项的跳转目标（PRIVACY_SETTINGS_PAGE、ABOUT_PAGE）必须在 RouterMap 中定义。line() 方法用于绘制分隔线，不可删除。
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页面
 * @domain: 绘画
 * @subPage: PrivacySettingsPage,AboutPage
 * @image: screenshots/person/setup.jpg
 * @component: CommonHeader, UserInfoRow, GenericCard, OHPage
 */
@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();

  aboutToAppear(): void {
    this.vm.getClearSize()
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
      Scroll() {
        Column() {
          Column() {
            GenericCard() {
              GenericCard() {
                UserInfoRow({
                  leftTitle: '清除缓存', rightContent: this.vm.cacheSize, rightOnClick: () => {
                    this.vm.showAlert()
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
                this.line()
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
        .margin({ bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .width('100%')
        .height('90%')
        .backgroundColor($r('sys.color.comp_background_gray'))
      }
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
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
