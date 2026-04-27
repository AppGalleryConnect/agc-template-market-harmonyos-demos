import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { CommonHeader, RouterMap, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';
import { LoginPageBuilder } from './LoginPage';
import { CMChatFactory } from 'instant_messaging';

/**
 * @usage: 设置页面，支持应用设置和账号管理功能。包含个人信息、隐私设置、清除缓存、版本检测、关于我们等功能入口。
 * 主要数据结构包括SettingAboutVM（设置视图模型）。包含if逻辑判断缓存大小显示和退出登录确认。
 * @layout: 页面采用Column垂直布局，顶部为导航栏，下方为设置项列表。设置项采用GenericCard卡片组件，每个设置项为Row横向布局（左侧标题+
 * 右侧箭头或操作按钮）。退出登录按钮独立显示在底部。
 * @constraints: 组件使用 @Local userInfo 通过 PersistenceV2.connect 持久化连接不可直接替换实例，vm 实例在初始化后不可修改
 * @domain: 社交交友
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页
 * @subPage: EditPersonalCenterPage,PersonalInfoView,AboutPage
 * @component: GenericCard,UserInfoRow,CommonHeader
 * @image: screenshot/tencent_search_on.png
 */

@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

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
      isFullScreen: true,
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
                  if (this.userInfo.isLogin) {
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
              this.line()
              Row() {
                Text('云端搜索')
                  .fontSize($r('sys.float.Subtitle_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.vm.getSearchModel() === 1 })
                  .margin({ right: 16 })
                  .selectedColor($r('sys.color.comp_background_emphasize'))
                  .onChange((isOn: boolean) => {
                    this.vm.setSearchModel(isOn ? 1 : 0)
                  })
              }
              .width('100%')
              .padding({ left: 10, top: 10 })
              .justifyContent(FlexAlign.Start)
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
            .onClick(async () => {
              if (this.userInfo.isLogin) {
                CMChatFactory.instance.removeFriendListener()
                CMChatFactory.instance.removeConversationListener()
                CMChatFactory.instance.removeAdvancedMsgListener()
                CMChatFactory.instance.logout().then(() => {
                  this.userInfo.isLogin = false;
                  this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
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
                }).catch(() => {
                  this.getUIContext().getPromptAction().showToast({ message: '退出登录失败', duration: 2000 });
                })
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
              }
            })
            .visibility(this.userInfo?.isLogin ? Visibility.Visible : Visibility.Hidden)
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
