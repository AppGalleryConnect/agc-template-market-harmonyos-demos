import { BarVM, HeaderView, MockService, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';

import { SettingPrivateSpacePasswordPageVM } from '../viewmodel/SettingPrivateSpacePasswordPageVM'
import { promptAction, window } from '@kit.ArkUI';
import { FileManagerPageVM } from '../viewmodel/FileManagerPageVM';

/**
 * @usage: 用于展示隐私空间设置密码页面。提供隐私空间密码设置功能，支持输入密码和确认密码，并进行密码验证。
 * 关键数据结构包括SettingPrivateSpacePasswordPageVM（设置隐私空间密码视图模型，包含inputPassword输入密码、
 * surePassword确认密码、savePrivateSpacePassword保存密码方法）。
 * 包含if逻辑：根据密码长度判断是否符合8-12位限制，根据两次输入密码是否一致判断是否允许保存。
 * @layout: 页面采用Column垂直布局。顶部是HeaderView导航栏（标题"密码设置"和返回按钮），
 * 第一个输入框TextInput（占位符"请输入密码"、高度44vp、圆角12vp、灰色背景#E4E7EB、上边距12vp），
 * 第二个输入框TextInput（占位符"请确认密码"、高度44vp、圆角12vp、灰色背景#E4E7EB、上边距24vp），
 * 底部是"确认"按钮Text（白色背景、宽度189vp、高度46vp、圆角23vp、蓝色文字、上边距80vp）。
 * @constraints: 密码长度必须在8-12位之间不可修改；两次输入密码必须一致；
 * 密码验证失败时显示Toast提示（"密码长度不符合要求"或"两次密码不一致"）；
 * 密码保存成功后调用savePrivateSpacePassword方法并返回上一页。
 * @isGen: true
 * @fileType: page
 * @subPage:
 * @domain: 云存储
 * @zhName: 设置隐私空间密码页面
 * @component: OHPage,HeaderView
 * @image: screenshot/file/settingpassword.jpg
 */

// 隐私空间设置密码
@ComponentV2
struct SettingPrivateSpacePasswordPage {
  vm: SettingPrivateSpacePasswordPageVM = new SettingPrivateSpacePasswordPageVM()
  @Param enterPrivateSpaceAfterCompleted: boolean = true
  currentWindow?: window.Window
  private pageInfo: OHPageConfig = new OHPageConfig({
    aboutToAppear: () => {
      try {
        // 键盘高度监听
        window.getLastWindow(getContext(this)).then((currentWindow) => {
          this.currentWindow = currentWindow
          this.currentWindow.setWindowPrivacyMode(true)
        })
      } catch (err) {
      }

    },
    aboutToDisappear: () => {
      this.currentWindow?.setWindowPrivacyMode(false)
    }
  });

  @Builder
  render() {
    Column() {
      HeaderView({
        title: $r('app.string.password_setting'),
        clickBackBtn: () => {
          phoneRouterControl.popPage();
        }
      })

      TextInput({ placeholder: $r('app.string.please_input_password'), text: this.vm.inputPassword })
        .placeholderColor($r('sys.color.font_secondary'))
        .width('calc(100% - 32vp)')
        .height(44)
        .fontSize(14)
        .fontColor(Color.Black)
        .type(InputType.Normal)
        .backgroundColor('#E4E7EB')
        .margin({ top: 12 })
        .borderRadius($r('app.float.vp_12'))
        .onChange((value: string) => {
          this.vm.inputPassword = value
        })

      TextInput({ placeholder: $r('app.string.please_sure_password'), text: this.vm.surePassword })
        .placeholderColor($r('sys.color.font_secondary'))
        .width('calc(100% - 32vp)')
        .height(44)
        .fontSize(14)
        .fontColor(Color.Black)
        .type(InputType.Normal)
        .backgroundColor('#E4E7EB')
        .margin({ top: 24 })
        .borderRadius($r('app.float.vp_12'))
        .onChange((value: string) => {
          this.vm.surePassword = value
        })

      Text($r('app.string.password_sure'))
        .backgroundColor(Color.White)
        .width(189)
        .height(46)
        .margin({ top: 80 })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .borderRadius(23)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (this.vm.inputPassword.length < 8 || this.vm.inputPassword.length > 12) {
            promptAction.showToast({ message: $r('app.string.password_not_limit') })
            return
          }

          if (this.vm.inputPassword !== this.vm.surePassword) {
            promptAction.showToast({ message: $r('app.string.password_not_same') })
            return
          }

          this.vm.savePrivateSpacePassword()

          // 设置完毕自动返回上一级
          if (!this.enterPrivateSpaceAfterCompleted) {
            phoneRouterControl.popPage()
            return
          }

          // 已开启隐私空间
          FileManagerPageVM.routerToPrivateSpace(MockService.privateSpaceInfo, true)
        })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ top: BarVM.instance.aiBarH })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      pageConfig: this.pageInfo
    })
  }
}

@Builder
export function SettingPrivateSpacePasswordPageBuilder(param: TValueType) {
  if (param === undefined) {
    SettingPrivateSpacePasswordPage()
  } else {
    SettingPrivateSpacePasswordPage({enterPrivateSpaceAfterCompleted: param as boolean})
  }
}