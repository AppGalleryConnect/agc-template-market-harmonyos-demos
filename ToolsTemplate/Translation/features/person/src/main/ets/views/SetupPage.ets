import { promptAction } from '@kit.ArkUI';
import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';

/**
 * @usage: 设置页面，提供个人信息、隐私设置、清除缓存、版本检测和关于我们等功能入口。支持退出登录。
 * 主要数据结构包括SettingAboutVM（设置视图模型）。
 * @layout: 页面采用OHPage包裹，内部Column垂直布局。顶部为CommonHeader导航栏，下方为Scroll滚动区域包含多个GenericCard卡片，
 * 每个卡片内含UserInfoRow设置项，底部为退出登录Button。
 * @constraints: 无
 * @domain: 翻译工具
 * @fileType: page
 * @isGen: true
 * @zhName: 设置页面
 * @subPage: EditPersonalCenterPage,PrivacySettingsPage,AboutPage
 * @component: CommonHeader,GenericCard,UserInfoRow,OHPage
 * @image: screenshot/person/SetupPage.jpg
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
