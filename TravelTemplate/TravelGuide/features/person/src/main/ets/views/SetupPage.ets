/**
 * @usage: 设置页面，提供实名认证、个人信息、隐私设置、清除缓存、版本检测、关于我们、退出登录等功能入口
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是可滚动的设置项列表，底部是退出登录按钮
 * @constraints: 实名认证和个人信息需要登录后才能访问；退出登录按钮仅在登录状态下显示
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页面
 * @domain: 旅游
 * @image: screenshots/person/Setup.jpg
 * @subPage: RealNameAuthPage,EditPersonalCenterPage,PrivacySettingsPage,AboutPage
 * @component: CommonHeader,GenericCard,UserInfoRow
 */
import { promptAction } from '@kit.ArkUI';
import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';
import { RealNameAuthPageBuilder } from 'module_auth';

@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();
  stack: NavPathStack = new NavPathStack()

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
      Scroll() {
        Column() {
          Column() {
            GenericCard() {
              UserInfoRow({
                leftTitle: '实名认证', rightOnClick: () => {
                  if (this.vm.userInfo.isLogin) {
                    phoneRouterControl.jumpPage({
                      pageName: RouterMap.REAL_NAME_AUTH_PAGE,
                      builder: wrapBuilder(RealNameAuthPageBuilder)
                    })
                  } else {
                    promptAction.showToast({ message: '请先登录' });
                  }
                }
              })
              this.line()
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
                leftTitle: '清除缓存', rightContent: this.vm.cacheSize, rightOnClick: () => {
                  this.vm.showAlert()
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
