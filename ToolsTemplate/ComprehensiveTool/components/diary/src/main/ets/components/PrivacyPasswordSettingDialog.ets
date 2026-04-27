import { common } from '@kit.AbilityKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { PrivacyPwdBuilderParams } from '../commons/Interface';
import { InputField } from './InputField'

@Builder
export function privacyPasswordSettingDialogBuilder(builderParams: PrivacyPwdBuilderParams) {
  PrivacyPasswordSettingDialog({
    confirm: builderParams.confirm,
    cancel: builderParams.cancel
  })
}

@ComponentV2
export struct PrivacyPasswordSettingDialog {
  @Event confirm: (pwd: string) => void;
  @Event cancel: () => void;
  @Local password: string = '';
  @Local confirmPassword: string = '';

  aboutToAppear(): void {
    this.setPrivacyWindow(true);
  }

  setPrivacyWindow(mode: boolean) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.windowStage.getMainWindowSync().setWindowPrivacyMode(mode)
  }

  handleConfirm() {
    if (!this.checkPwd()) {
      return
    }

    this.confirm?.(this.password)
  }

  // 校验密码
  checkPwd() {
    if (!this.password) {
      this.toastMsg('请输入密码');
      return false;
    }
    if (this.password.length < 6) {
      this.toastMsg('请输入6位密码');
      return false;
    }
    if (!this.confirmPassword) {
      this.toastMsg('请确认密码');
      return false;
    }
    if (this.password !== this.confirmPassword) {
      this.toastMsg('两次输入不一致');
      return false;
    }

    return true;
  }

  toastMsg(message: string) {
    ToastDialog.showToast({
      message: message,
      toastAlignment: DialogAlignment.Top,
      toastOffset: { dx: 0, dy: 200 }
    })
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Text('设置隐私日记密码')
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .lineHeight(27)
          .margin({ top: 16, bottom: 16 })

        InputField({
          label: '密码',
          value: this.password!!,
          placeholder: '请输入6位数密码'
        })

        InputField({
          label: '确认密码',
          value: this.confirmPassword!!,
          placeholder: '请再一次输入密码'
        })

        Flex({ alignItems: ItemAlign.Center }) {
          Button('取消', { buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontColor($r('sys.color.font_primary'))
            .width('100%')
            .onClick(() => {
              this.cancel?.()
            })

          Divider().strokeWidth(1).height(24).color('#0d000000').vertical(true)

          Button('确认', { buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontColor($r('app.color.diary_primary_color'))
            .width('100%')
            .onClick(() => {
              this.handleConfirm()
            })
        }
        .margin({ top: 8, bottom: 24 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(32)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .padding(16)
    .onDisAppear(() => {
      this.setPrivacyWindow(false)
    })
  }
}