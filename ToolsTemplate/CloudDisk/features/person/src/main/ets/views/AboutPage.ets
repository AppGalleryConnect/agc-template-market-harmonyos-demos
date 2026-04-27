import { Constants, HeaderView, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { common } from '@kit.AbilityKit';
import { checkUpdate } from 'check_app_update';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';

/**
 * @usage: 用于展示关于应用页面。提供应用基本信息展示和版本更新检查功能。
 * 关键数据结构包括needUpdate（是否需要更新的布尔值）、checkUpdate（版本检查函数，返回Promise<Number>，0表示不存在新版本、
 * 1表示存在新版本）、information（信息字符串）、service（服务字符串）、business（业务与隐私声明字符串）。
 * 包含if逻辑：根据checkUpdate返回值判断是否存在新版本（version === 1），当前mock为始终存在新版本。
 * @layout: 页面采用Column垂直布局。顶部是HeaderView导航栏（标题"关于应用"和返回按钮，高度82vp，底部对齐），
 * 主体Column（上边距80vp，左右内边距16vp）居中显示应用图标（77x77）、应用名称"云盘"（字号16、高度19、上边距16vp）、
 * 当前版本号"当前版本13.12.1"（字号13、高度15、灰色字体#9DA3AA、上边距8vp），
 * 下方是隐私协议入口Row（白色背景、圆角10vp、高度60vp、上边距60vp，包含标题"隐私协议"左对齐和右箭头图标20x20右对齐）。
 * @constraints: 应用图标app_icon、名称"云盘"和版本号"当前版本13.12.1"固定显示；
 * 版本检查由check_app_update组件的checkUpdate方法提供不可修改；隐私协议入口必须保留并跳转到PRIVACY_SETTINGS_PAGE；
 * 页面背景色为bg_color不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 关于应用页面
 * @subPage: PrivacySettingsPage
 * @component: OHPage,HeaderView
 */

@ComponentV2
export struct AboutPage {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'
  @Local needUpdate: boolean = false;

  checkAppUpdate() {
    checkUpdate(this.getUIContext().getHostContext() as common.UIAbilityContext)
      .then((version: Number) => {
        // 0 不存在新版本， 1 存在新版本
        if (version === 1) {
          this.needUpdate = true;
        } else {
          // mock 新版本
          this.needUpdate = true;
        }
      })
  }

  aboutToAppear(): void {
    this.checkAppUpdate()
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  @Builder
  render() {
    Column() {
      Column() {
        HeaderView({
          title: $r('app.string.about_app'),
          clickBackBtn: () => {
            phoneRouterControl.popPage();
          }
        })
      }
      .height(82)
      .justifyContent(FlexAlign.End)

      Column() {
        Image($r('app.media.app_icon'))
          .width(77)
          .height(77)
        Text('云盘')
          .fontColor($r('app.color.black_color'))
          .margin({ top: 16 })
          .fontSize(16)
          .height(19)
          .fontWeight(500)
        Text('当前版本13.12.1')
          .fontColor($r('app.color.gray_color_9DA3AA'))
          .fontSize(13)
          .height(15)
          .fontWeight(400)
          .margin({ top: 8 })
        Row() {
          Text('隐私协议')
            .font({
              size: 15,
              weight: 500
            })
            .height(60)
            .fontColor($r('app.color.dark_color_444444'))
            .margin({left : 10})
          Blank()
          Image($r('app.media.iconRight'))
            .width(20)
            .height(20)
        }
        .borderRadius(10)
        .backgroundColor($r('app.color.white'))
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.PRIVACY_SETTINGS_PAGE,
            builder: wrapBuilder(PrivacySettingsPageBuilder)
          })
        })
        .justifyContent(FlexAlign.Start)
        .padding({ right: 8 })
        .width(Constants.FULL_SIZE)
        .margin({ top: 60 })
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: 80 })
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.bg_color'))
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}
