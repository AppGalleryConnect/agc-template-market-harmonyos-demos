import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigInfo } from '../common/ConfigModel';
import { ObservedInfoItem } from '../common/FormModel';
import { WindowModel } from '../common/WindowModel';
import { Constants } from '../common/Constant';
import { ConfirmButtonModifier, SheetColumnModifier } from '../common/CustomModifier';
import { encryptPhone, isPhoneNumberValid } from '../common/Util';

@ComponentV2
export struct EnterPhoneNumber {
  @Require @Param data: ObservedInfoItem;
  @Local oldPhoneValue: string = '';
  @Local sheetColumnModifier: SheetColumnModifier = new SheetColumnModifier(Constants.PADDING_S);
  @Local confirmButtonModifier: ConfirmButtonModifier = new ConfirmButtonModifier();
  @Local sheetPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.oldPhoneValue = encryptPhone(this.data.value as string);
  }

  build() {
    Navigation(this.sheetPathStack) {
      Column() {
        Text('手机号码')
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .height(56)

        Scroll() {
          Column() {
            Row() {
              TextInput({ text: $$this.oldPhoneValue })
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.background_primary'))
                .constraintSize({ minHeight: 48 })
                .enabled(false)
            }
            .width(Constants.FULL_PERCENT)
            .padding({
              top: Constants.PADDING_4XL,
              bottom: Constants.PADDING_S,
            })

            Row({ space: Constants.SPACE_S }) {
              SymbolGlyph($r('sys.symbol.exclamationmark_circle'))
                .fontSize(16)
                .fontColor([$r('sys.color.icon_tertiary')])
              Text('注意：变更手机号，您需要解绑当前手机号，请谨慎操作！')
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_tertiary'))
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
            }
            .width(Constants.FULL_PERCENT)
            .alignItems(VerticalAlign.Top)

            Blank()

            Column() {
              Button('更换')
                .attributeModifier(this.confirmButtonModifier)
                .onClick(() => {
                  this.sheetPathStack.pushPathByName('OldPhone', this.data);
                })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)

          }
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .attributeModifier(this.sheetColumnModifier)
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }
}

@Builder
export function oldPhoneBuilder() {
  OldPhone()
}

@ComponentV2
struct OldPhone {
  @Local sheetPathStack: NavPathStack = new NavPathStack();
  @Local data: ObservedInfoItem = new ObservedInfoItem();

  build() {
    NavDestination() {
      EnterPhoneNumberCore({
        oldValue: this.data.value as string,
        codeLength: this.data.phoneInfo.codeLength ?? 6,
        sendCode: this.data.phoneInfo.sendCode,
        verifyCode: this.data.phoneInfo.verifyCode,
        phoneReadonly: true,
        confirmBtnLabel: '下一步',
        confirmBtnEvent: () => {
          this.sheetPathStack.replacePathByName('NewPhone', this.data);
        },
      })
    }
    .title('当前号码')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: Constants.PADDING_S,
    })
    .onReady((context) => {
      this.sheetPathStack = context.pathStack;
      this.data = context.pathInfo.param as ObservedInfoItem;
    })
  }
}

@Builder
export function newPhoneBuilder() {
  NewPhone()
}

@ComponentV2
struct NewPhone {
  @Local data: ObservedInfoItem = new ObservedInfoItem();

  build() {
    NavDestination() {
      EnterPhoneNumberCore({
        oldValue: this.data.value as string,
        codeLength: this.data.phoneInfo.codeLength ?? 6,
        sendCode: this.data.phoneInfo.sendCode,
        verifyCode: this.data.phoneInfo.verifyCode,
        confirmBtnLabel: '确认',
        confirmBtnEvent: (phone?: string) => {
          this.data.onChange(phone);
          this.data.showSheet = false;
        },
      })
    }
    .title('新号码')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: Constants.PADDING_S,
    })
    .onReady((context) => {
      this.data = context.pathInfo.param as ObservedInfoItem;
    })
  }
}

@ComponentV2
export struct EnterPhoneNumberCore {
  @Param oldValue: string = '';
  @Param codeLength: number = 6;
  @Param phoneReadonly: boolean = false;
  @Param confirmBtnLabel: string = '';
  @Event sendCode: (phone: string) => Promise<void> = () => Promise.resolve();
  @Event verifyCode: (phone: string, code: string) => Promise<void> = () => Promise.resolve();
  @Event confirmBtnEvent: (phone?: string) => void = (phone?: string) => {
  };
  @Local phoneValue: string = '';
  @Local codeValue: string = '';
  @Local sheetColumnModifier: SheetColumnModifier = new SheetColumnModifier();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!
  @Local receivingCode: boolean = false;
  @Local countdown: number = 60;
  @Local reGetCode: boolean = false;
  @Local timer: number = 0;
  @Local verifyCodeValid: boolean = true;
  @Local isKeyboardPopUp: boolean = false;
  @Local focusPhoneInput: boolean = false;
  @Local phoneErrorTip: string = '';
  @Local sendCodeLoading: boolean = false;
  @Local confirmLoading: boolean = false;

  aboutToAppear(): void {
    if (this.phoneReadonly) {
      this.phoneValue = encryptPhone(this.oldValue);
    }
    this.windowModel.registerKeyboardListener(this.onKeyBoardCB);
  }

  aboutToDisappear(): void {
    this.codeValue = '';
    this.windowModel.unRegisterKeyboardListener(this.onKeyBoardCB);
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    this.isKeyboardPopUp = height > 0;
    this.sheetColumnModifier.needAvoidBottom = !this.isKeyboardPopUp;
  };

  build() {
    Scroll() {
      Column() {
        Row() {
          if (this.phoneReadonly) {
            Text(this.phoneValue)
              .width(Constants.FULL_PERCENT)
              .constraintSize({ minHeight: 48 })
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_tertiary'))
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(20)
              .enabled(false)
              .padding({
                left: 16,
                right: 16,
              })
          } else {
            TextInput({ text: $$this.phoneValue, placeholder: '请输入新手机号码' })
              .type(InputType.PhoneNumber)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.background_primary'))
              .placeholderColor($r('sys.color.font_secondary'))
              .borderWidth(1)
              .borderColor(this.phoneErrorTip.length ? $r('sys.color.warning') :
              Color.Transparent)
              .cancelButton({
                style: this.focusPhoneInput ? CancelButtonStyle.INPUT : CancelButtonStyle.INVISIBLE,
                icon: { size: 24 },
              })
              .constraintSize({ minHeight: 48 })
              .onFocus(() => {
                this.focusPhoneInput = true;
              })
              .onBlur(() => {
                this.focusPhoneInput = false;
                this.checkPhoneErrorTip();
              })
              .onChange(() => {
                this.phoneErrorTip = '';
              })
          }
        }
        .width(Constants.FULL_PERCENT)
        .padding({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })

        Text(this.phoneErrorTip)
          .fontSize(10)
          .fontColor($r('sys.color.warning'))
          .alignSelf(ItemAlign.Start)
          .padding({
            left: Constants.SPACE_S,
            right: Constants.SPACE_S,
          })
          .visibility(this.phoneErrorTip.length ? Visibility.Visible : Visibility.None)

        Stack() {
          TextInput({ text: $$this.codeValue, placeholder: '请输入验证码' })
            .type(InputType.Number)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.background_primary'))
            .placeholderColor($r('sys.color.font_secondary'))
            .borderWidth(1)
            .borderColor(this.verifyCodeValid ? Color.Transparent : $r('sys.color.warning'))
            .maxLength(this.codeLength)
            .constraintSize({ minHeight: 48 })
            .onChange(() => {
              this.verifyCodeValid = true;
            })

          Button() {
            Row() {
              if (this.sendCodeLoading) {
                LoadingProgress()
                  .width(20)
                  .aspectRatio(1)
                  .color(this.configInfo.themeColor)
              } else {
                Text(this.codeBtnLabel)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor(this.codeBtnFgColor)
              }
            }
          }
          .width(72)
          .height(28)
          .padding(0)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ right: 12 })
          .enabled(this.allowSendCode)
          .onClick(() => {
            this.codeValue = '';
            this.checkPhoneErrorTip();
            if (this.phoneErrorTip.length) {
              return;
            }
            this.sendCodeLoading = true;
            this.sendCode(this.realPhoneValue)
              .then(() => {
                this.verifyCodeValid = true;
                this.receivingCode = true;
                this.countdown = 60;
                this.timer = setInterval(() => {
                  if (this.countdown === 1) {
                    clearInterval(this.timer);
                    this.reGetCode = true;
                    this.receivingCode = false;
                  } else {
                    this.countdown--;
                  }
                }, 1000)
              })
              .catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: '获取验证码出现异常，请重试' });
              })
              .finally(() => {
                this.sendCodeLoading = false;
              })
          })
        }
        .alignContent(Alignment.End)
        .width(Constants.FULL_PERCENT)
        .padding({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })

        Text('验证码错误或已过期')
          .fontSize(10)
          .fontColor($r('sys.color.warning'))
          .alignSelf(ItemAlign.Start)
          .padding({
            left: Constants.SPACE_S,
            right: Constants.SPACE_S,
          })
          .visibility(this.verifyCodeValid ? Visibility.None : Visibility.Visible)

        Blank()

        Button() {
          Row({ space: Constants.SPACE_XS }) {
            LoadingProgress()
              .width(20)
              .aspectRatio(1)
              .color($r('sys.color.icon_on_primary'))
              .visibility(this.confirmLoading ? Visibility.Visible : Visibility.None)
            Text(this.confirmBtnLabel)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
          }
        }
        .width(Constants.FULL_PERCENT)
        .height(40)
        .backgroundColor(this.configInfo.themeColor)
        .enabled(this.allowSubmit)
        .onClick(() => {
          this.checkPhoneErrorTip();
          if (this.phoneErrorTip.length) {
            return;
          }
          this.confirmLoading = true;
          this.verifyCode(this.realPhoneValue, this.codeValue)
            .then(() => {
              this.confirmBtnEvent(this.phoneValue);
            })
            .catch(() => {
              this.verifyCodeValid = false;
            })
            .finally(() => {
              this.confirmLoading = false;
            })
        })
      }
      .attributeModifier(this.sheetColumnModifier)
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }

  checkPhoneErrorTip() {
    this.phoneErrorTip = '';
    if (this.phoneReadonly) {
      return;
    }
    if (this.phoneValue && !isPhoneNumberValid(this.phoneValue)) {
      this.phoneErrorTip = '请输入11位手机号';
      return;
    }
    if (this.phoneValue === this.oldValue) {
      this.phoneErrorTip = '您输入的手机号不能与当前绑定的手机号相同';
    }
  }

  @Computed
  get realPhoneValue() {
    return this.phoneReadonly ? this.oldValue : this.phoneValue;
  }

  @Computed
  get allowSendCode() {
    if (this.sendCodeLoading) {
      return false;
    }
    if (this.receivingCode) {
      return false;
    }
    if (this.phoneValue.length <= 0) {
      return false;
    }
    return true;
  }

  @Computed
  get allowSubmit() {
    if (this.confirmLoading) {
      return false;
    }
    if (this.phoneValue.length <= 0) {
      return false;
    }
    if (this.codeValue.length < this.codeLength) {
      return false;
    }
    if (this.phoneErrorTip.length > 0) {
      return false;
    }
    if (!this.verifyCodeValid) {
      return false;
    }
    return true;
  }

  @Computed
  get codeBtnLabel() {
    if (this.receivingCode) {
      return this.countdown.toString() + 'S';
    }
    if (this.reGetCode) {
      return '重新获取';
    }
    return '验证码';
  }

  @Computed
  get codeBtnFgColor() {
    if (this.receivingCode) {
      return $r('sys.color.font_tertiary');
    }
    return this.configInfo.themeColor;
  }
}
