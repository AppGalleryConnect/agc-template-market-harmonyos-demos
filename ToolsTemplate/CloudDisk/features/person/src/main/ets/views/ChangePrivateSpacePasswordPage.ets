import { Constants, GlobalContext, HeaderView, TCLogger } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { TextInPutRow } from '../comp/TextInPutRow'
import { PasswordChangeViewModel } from '../viewmodel/PasswordChangeViewModel'
import { promptAction, window } from '@kit.ArkUI';
import { PasswordCard } from '../comp/PasswordCard';

const TAG = 'ChangePrivateSpacePasswordPage'

@Builder
export function ChangePrivateSpacePasswordPageBuilder() {
  ChangePrivateSpacePasswordPage()
}

/**
 * @usage: 用于展示修改隐私空间密码页面。提供用户修改隐私空间密码的功能，支持输入原密码、新密码和确认密码。
 * 关键数据结构包括PasswordChangeViewModel（密码修改视图模型，包含setOldPasswoed设置原密码、setNewPasswoed设置新密码、
 * setSurePasswoed设置确认密码、savePrivateSpacePassword保存密码、sendMessage发送消息回调、
 * savePassWoedSuccess保存成功回调）、isEdite（是否可点击确认按钮的布尔值）。
 * 包含if逻辑：根据isEdite判断是否允许点击确认按钮，根据密码验证结果显示Toast提示并决定是否返回上一页，
 * 返回时根据isEdite判断是否弹出"确定退出"对话框。
 * @layout: 页面采用Column垂直布局（间距12vp）。顶部是HeaderView导航栏（标题"修改隐私空间密码"和返回按钮，上边距24vp），
 * 主体是PasswordCard卡片容器（圆角16vp，左右内边距16vp），包含3个TextInPutRow输入行（原密码、新密码、确认密码），
 * 每行之间有Divider分割线（1px宽度，左右内边距12vp）。底部是"确认"Button（字号16、白色文字、蓝色背景#2FAFFF、
 * 圆角24vp、高度43vp、左右内边距24vp、底部内边距52vp）。
 * @constraints: 密码验证逻辑由PasswordChangeViewModel处理不可修改；确认按钮的可点击状态由isEdite控制；
 * 保存成功后延迟1.5秒返回上一页；返回时如果isEdite为true需要弹出确认对话框；
 * 对话框标题"确定退出"、内容"未保存密码"、取消和确定按钮颜色固定。
 * @isGen: true
 * @fileType: page
 * @zhName: 修改隐私空间密码页面
 * @component: OHPage,HeaderView,PasswordCard,TextInPutRow
 */

@ComponentV2
struct ChangePrivateSpacePasswordPage {
  passWordVM = new PasswordChangeViewModel()
  currentWindow?: window.Window
  private pageInfo: OHPageConfig = new OHPageConfig({
    onBackPress: () => {
      return this.dealWithBackPress()
    },
    aboutToAppear: () => {
      try {
        // 键盘高度监听
        window.getLastWindow(getContext(this)).then((currentWindow) => {
          this.currentWindow = currentWindow
          this.currentWindow.setWindowPrivacyMode(true)
        })
      } catch (err) {
        TCLogger.info(TAG, `Failed to get last window, code: ${err.code}, message: ${err.message}`);
      }
    },
    aboutToDisappear: () => {
      this.currentWindow?.setWindowPrivacyMode(false)
    }
  });

  private dealWithBackPress(): boolean {
    if (!this.passWordVM.canBackNotSave()) {
      GlobalContext.getUIContext().showAlertDialog({
        title: $r('app.string.sure_exit'),
        message: $r('app.string.not_save_secret'),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        showInSubWindow: true,
        isModal: true,
        buttonDirection: DialogButtonDirection.HORIZONTAL,
        buttons: [
          {
            value: $r('app.string.cancel'),
            action: () => {
            }
          },
          {
            value: $r('app.string.sure'),
            action: () => {
              phoneRouterControl.popPage();
            }
          }
        ]
      })
    } else {
      phoneRouterControl.popPage();
    }
    return true
  }

  aboutToAppear(): void {
    this.passWordVM.savePassWoedSuccess = (resulte: boolean, content: string | Resource) => {
      promptAction.showToast({ message: content, duration: 1000 })
      if (resulte) {
        setTimeout(() => {
          phoneRouterControl.popPage();
        }, 1500)
      }
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageInfo
    })
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  @Builder
  render() {
    Column({ space: 12 }) {
      Column() {
        HeaderView({
          title: $r('app.string.change_private_space_secret'),
          clickBackBtn: () => {
            this.dealWithBackPress()
          }
        })
          .margin({ top: 24 })
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('app.color.white'))

      Column() {
        PasswordCard() {
          TextInPutRow({
            title: $r('app.string.old_secret'),
            placeHolder: $r('app.string.input_old_secret'),
            blockContent: (value: string) => {
              TCLogger.debug(TAG, `原密码${value}}`)
              this.passWordVM.setOldPasswoed(value)
            }
          })
          this.line()
          TextInPutRow({
            title: $r('app.string.new_secret'),
            placeHolder: $r('app.string.input_new_secret'),
            blockContent: (value: string) => {
              TCLogger.debug(TAG, `新密码${value}}`)
              this.passWordVM.setNewPasswoed(value)
            }
          })
          this.line()
          TextInPutRow({
            title: $r('app.string.sure_secret'),
            placeHolder: $r('app.string.sure_new_secret'),
            blockContent: (value: string) => {
              TCLogger.debug(TAG, `确认密码${value}}`)
              this.passWordVM.setSurePasswoed(value)
            }
          })
        }
      }
      .width(Constants.FULL_SIZE)
      .padding({ left: 16, right: 16 })

      Blank()

      Row() {
        Text('确认')
          .font({
            size: 16,
            weight: 400
          })
          .onClick(() => {
            if (this.passWordVM.checkResult()) {
              // 可更换密码
              TCLogger.debug(TAG, ' 可以确认')
              this.passWordVM.savePrivateSpacePassword()
            }
          })
          .fontColor($r('app.color.white'))
          .textAlign(TextAlign.Center)
          .width(Constants.FULL_SIZE)
          .height(43)
          .borderRadius(24)
          .backgroundColor($r('app.color.blue_color_2FAFFF'))
      }
      .padding({ left: 24, right: 24, bottom: 52 })
      .width(Constants.FULL_SIZE)

    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('app.color.bg_color'))

  }
}