import { common } from '@kit.AbilityKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { PrivacyPwdBuilderParams } from '../commons/Interface';
import { DiaryExtraInfo } from '../models/Diary';
import { PasswordCodeInput } from './PasswordCodeInput';

@Builder
export function privacyPwdInputDialogBuilder(builderParams: PrivacyPwdBuilderParams) {
  PrivacyPwdInputDialog({
    confirm: builderParams.confirm,
    cancel: builderParams.cancel
  })
}


@ComponentV2
export struct PrivacyPwdInputDialog {
  @Event confirm: () => void;
  @Event cancel: () => void;
  @Local password: string = '';
  @Local diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  aboutToAppear(): void {
    this.setPrivacyWindow(true);
  }

  setPrivacyWindow(mode: boolean) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.windowStage.getMainWindowSync().setWindowPrivacyMode(mode)
  }

  handleConfirm() {
    let pwd = this.diaryExtraInfo.password;
    // 未输入
    if (!this.password) {
      this.toastMsg('请先输入密码');
      return
    }
    // 密码长度小于6
    if (this.password.length < 6) {
      this.toastMsg('请输入6位密码');
      return
    }
    // 密码输入错误
    if (this.password !== pwd) {
      this.toastMsg('隐私密码输入错误');
      return
    }
    this.confirm?.()
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
        Text('私密日记')
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .lineHeight(27)
          .margin({ top: 16, bottom: 16 })

        Text('请输入密码验证信息')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)

        PasswordCodeInput({
          value: this.password!!
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