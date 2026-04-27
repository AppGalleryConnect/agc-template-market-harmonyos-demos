/**
 * @usage: 设置页面,用户从个人中心页点击设置入口后跳转到此页面进行应用设置。
 * 提供应用版本检测、隐私设置、关于我们、退出登录等功能。支持检测应用更新、查看隐私设置、
 * 查看关于信息、退出登录等操作。未登录用户不显示退出登录按钮。
 * @layout: 页面采用OHPage容器包裹Column垂直布局,顶部为CommonHeader导航头部,
 * 中间为Scroll滚动容器包裹设置项列表(使用GenericCard卡片容器包裹UserInfoRow列表项),
 * 包含检测版本、隐私设置、关于我们等功能项,底部为退出登录按钮(仅登录用户可见)。
 * @constraints: 退出登录功能仅在用户已登录时显示和可用。检测版本功能需要网络权限。
 * 隐私设置和关于我们页面不需要登录即可访问。
 * @domain: 音频编辑
 * @zhName: 设置页面
 * @isGen: true
 * @fileType: page
 * @subPage: PrivacySettingsPage,AboutPage
 * @component: CommonHeader,UserInfoRow,GenericCard
 * @image: screenshots/person/setup.jpg
 */
import { promptAction } from '@kit.ArkUI';
import { BarVM, RouterMap } from 'common';
import { CommonHeader } from 'audio_common'
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AboutPageBuilder } from './AboutPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';

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
      Row(){
        CommonHeader({
          title: '设置',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
          backgroundColorParam:'#FFF'
        })
      }
      .width('100%')
      .padding({left:17,top:10})
      .backgroundColor('#FFF')
      Scroll() {
        Column() {
          Column() {
            GenericCard() {
              UserInfoRow({
                leftTitle: '检测版本', rightOnClick: () => {
                  this.vm.checkAppUpdate()
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
                leftTitle: '关于我们', rightOnClick: () => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.ABOUT_PAGE,
                    builder: wrapBuilder(AboutPageBuilder)
                  })
                }
              })
            }
          }
          .width('100%')

          Row(){
            Text('退出登录')
              .fontColor('#666666')
              .fontSize(15)
              .fontWeight(500)
          }
          .margin({top: 12})
          .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFF')
            .width('100%')
            .height(55)
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
        .justifyContent(FlexAlign.Start)
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
    .padding({
      top: BarVM.instance.staBarH
    })
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
