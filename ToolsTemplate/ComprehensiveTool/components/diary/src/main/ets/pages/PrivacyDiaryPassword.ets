import { common } from '@kit.AbilityKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { InputField } from '../components/InputField';
import { DiaryExtraInfo } from '../models/Diary';
import { DiaryUtil } from '../utils/DiaryUtil';

@Builder
export function PrivacyDiaryPasswordBuilder() {
  PrivacyDiaryPassword()
}


@ComponentV2
export struct PrivacyDiaryPassword {
  diaryUtil: DiaryUtil = DiaryUtil.instance;
  pathStack: NavPathStack = new NavPathStack()
  @Local password: string = '';
  @Local oldPassword: string = '';
  @Local confirmPassword: string = '';
  @Local diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  @Computed
  get hasOldPwd() {
    return Boolean(this.diaryExtraInfo.password);
  }

  setPrivacyWindow(mode: boolean) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.windowStage.getMainWindowSync().setWindowPrivacyMode(mode)
  }

  confirm() {
    if (!this.checkOldPwd()) {
      return;
    }

    if (!this.checkPwd()) {
      return;
    }

    this.diaryExtraInfo.password = this.password
    this.toastMsg('隐私日记密码设置成功');
    this.pathStack.pop()
  }

  // 校验旧密码
  checkOldPwd() {
    if (this.hasOldPwd) {
      let pwd = this.diaryExtraInfo.password;
      if (!pwd || !this.oldPassword) {
        this.toastMsg('请输入密码');
        return false;
      }
      if (pwd !== this.oldPassword) {
        this.toastMsg('原密码错误，请重新输入');
        return false;
      }
    }
    return true;
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
      toastAlignment: DialogAlignment.Center
    })
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Column({ space: 24 }) {
          InputField({
            label: '旧密码',
            value: this.oldPassword!!,
            placeholder: '请输入6位数密码'
          })
            .visibility(this.hasOldPwd ? Visibility.Visible : Visibility.None)

          InputField({
            label: this.hasOldPwd ? '新密码' : '密码',
            value: this.password!!,
            placeholder: '请输入6位数密码'
          })

          InputField({
            label: '确认密码',
            value: this.confirmPassword!!,
            placeholder: '请再一次输入密码'
          })
        }
        .id('content')

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text('确认')
              .fontSize(16)
              .fontWeight(500)
              .fontColor(Color.White)
              .lineHeight(21)
          }
          .margin({ bottom: 16 })
          .height(40)
          .width('100%')
          .backgroundColor($r('app.color.diary_primary_color'))
          .onClick(() => {
            this.confirm()
          })
        }
        .id('btn')
        .width('100%')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })
      }
      .width('100%')
      .padding(16)
    }
    .title('设置隐私日记密码')
    .onReady((cxt)=> {
      this.pathStack = cxt.pathStack;
    })
    .onWillShow(() => {
      this.setPrivacyWindow(true);
    })
    .onWillHide(() => {
      this.setPrivacyWindow(false);
    })
  }
}