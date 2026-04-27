import { promptAction } from '@kit.ArkUI';
import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';
import { Constants } from 'common';

/**
 * @usage: 设置页面，提供个人信息、隐私设置、清除缓存、版本检测、关于我们、退出登录等功能入口。未登录用户点击个人信息会提示先登录，已登录用户可以
 * 退出登录。
 * @layout: 页面采用垂直布局（Column），顶部为标题栏（返回按钮 + 标题），下方为滚动内容区，包含多个功能卡片（GenericCard），每个卡片内包含多
 * 个功能行（UserInfoRow）。底部为退出登录按钮（仅登录用户可见）。
 * @constraints: 个人信息、隐私设置、关于我们功能会跳转到对应页面。清除缓存功能会弹出确认对话框。版本检测功能调用 checkAppUpdate 方法。退出
 * 登录功能会清空用户信息并返回上一页。
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页面
 * @subPage: EditPersonalCenterPage,PrivacySettingsPage,AboutPage
 * @component: CommonHeader,UserInfoRow,GenericCard
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
            .margin({ bottom: 10 })
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
    .padding({ top: Constants.PADDING_7XL })
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
