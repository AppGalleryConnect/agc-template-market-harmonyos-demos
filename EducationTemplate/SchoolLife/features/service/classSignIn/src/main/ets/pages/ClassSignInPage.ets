import { UIVerifyCodeInput, VerifyCodeType, VerifyEventType } from '@hw-agconnect/ui-verify-code';
import { ComponentConst, LoadingPageWrapper, NavigateBar } from 'componentlib';
import { ClassSignInVM, SignState } from '../viewmodel/ClassSignInVM';
import { common } from '@kit.AbilityKit';

@Builder
export function classSignInPageBuilder() {
  NavDestination() {
    ClassSignInPage()
  }
  .hideTitleBar(true)
  .hideToolBar(true)
}

@ComponentV2
struct ClassSignInPage {
  @Local vm: ClassSignInVM = ClassSignInVM.instance;
  @Local verifyCodeCount: number = 4;
  @Local verifyCode: string = '';
  @Local showErrorTips: boolean = false;

  private _context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    // 申请位置权限，用于签到
    this.vm.requestLocationPermission();
  }

  aboutToDisappear(): void {
    this.vm.resetState();
  }

  build() {
    LoadingPageWrapper({ isLoading: this.vm.isSignLoading, loadingText: $r('app.string.signing') }) {
      Stack() {
        // 背景渐变
        Column()
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              [$r('sys.color.multi_color_09'), 0.0],
              [$r('sys.color.background_secondary'), 1.0],
            ],
          })
          .width(ComponentConst.FULL_PARENT)
          .height('25%')

        Column() {
          // 标题
          NavigateBar({ title: $r('app.string.class_sign_in'), enableBackward: true })

          Scroll() {
            RelativeContainer() {
              // 签到码输入框
              this.signInInputBuilder();

              // 说明文案
              this.signInTipsBuilder();

              // 确认签到按钮
              Button() {
                Text($r('app.string.confirm_sign_in'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor(Color.White)
              }
              .backgroundColor($r('sys.color.multi_color_09'))
              .height(40)
              .padding({
                top: $r('app.string.padding_xs'),
                bottom: $r('app.string.padding_xs'),
              })
              .enabled(
                this.verifyCode.length === this.verifyCodeCount &&
                this.vm.hasLocationPermission &&
                  this.vm.signState !== SignState.SUCCESS
              )
              .alignRules({
                top: ComponentConst.bindBottom('sign_in_tip_content'),
                left: ComponentConst.bindStart(),
                right: ComponentConst.bindEnd(),
              })
              .margin({
                top: $r('app.string.margin_xl'),
                left: 16,
                right: 16,
              })
              .onClick(async () => {
                await this.vm.classSignIn(this.verifyCode);
                if (this.vm.signState === SignState.FAILED) {
                  this.verifyCodeError();
                }
              })
            }
            .width(ComponentConst.FULL_PARENT)
            .height(ComponentConst.AUTO_SIZE)
          }
          .scrollBar(BarState.Off)
          .align(Alignment.TopStart)
          .width(ComponentConst.FULL_PARENT)
          .layoutWeight(1)
        }
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.FULL_PARENT)
        .padding({
          top: ComponentConst.PAGE_VERTICAL_PADDING,
          bottom: ComponentConst.PAGE_VERTICAL_PADDING,
        })
      }
      .alignContent(Alignment.TopStart)
      .width(ComponentConst.FULL_PARENT)
      .height(ComponentConst.FULL_PARENT)
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }

  @Builder signInInputBuilder() {
    Image($r('app.media.ic_sign_in_code_bg'))
      .objectFit(ImageFit.Fill)
      .height(80)
      .alignRules({
        left: ComponentConst.bindStart(),
        right: ComponentConst.bindEnd(),
      })
      .margin({
        top: $r('app.string.margin_m'),
        left: $r('app.string.margin_l'),
        right: $r('app.string.margin_l'),
      })
      .id('sign_in_code_bg')

    RelativeContainer() {
      if (this.vm.signState === SignState.SUCCESS) {
        Column() {
          Text(this.vm.verifyCourseName)
            .fontSize($r('app.string.font_size_16'))
            .fontWeight(FontWeight.Bold)

          Image($r('app.media.ic_sign_in_success'))
            .size(ComponentConst.ICON_SIZE_XM)
            .objectFit(ImageFit.Fill)
            .margin({ top: $r('app.string.margin_m') })

          Text($r('app.string.sign_in_success'))
            .fontSize($r('app.string.font_size_16'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: $r('app.string.margin_m') })
        }
        .height(ComponentConst.AUTO_SIZE)
        .width(ComponentConst.FULL_PARENT)
        .id('verify_tips')
      } else {
        Text($r('app.string.input_sign_code'))
          .fontSize($r('app.string.font_size_16'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            middle: ComponentConst.bindHorizontalCenter(),
          })
          .id('verify_tips')
      }

      UIVerifyCodeInput({
        codeCount: this.verifyCodeCount,
        codeType: VerifyCodeType.NUMBER,
        verifyEnable: this.vm.signState !== SignState.SUCCESS,
        onFinishInput: (code: string) => {
          this.verifyCode = code;
          this.verifyStateReset();
        },
        onCodeChange: (code: string) => {
          this.verifyCode = code;
        },
      }).width(196)
        .margin({ top: ComponentConst.CARD_SPACE_LARGE })
        .alignRules({
          top: ComponentConst.bindBottom('verify_tips'),
          middle: ComponentConst.bindHorizontalCenter(),
        })
        .id('verify_input')

      if (this.showErrorTips) {
        Row() {
          Image($r('app.media.ic_code_error_tips'))
            .size(ComponentConst.ICON_SIZE_TINY)
            .objectFit(ImageFit.Fill)

          Text($r('app.string.verify_code_error_tips'))
            .fontSize($r('app.string.font_size_8'))
            .fontColor($r('app.color.warning_red'))
            .margin({ left: $r('app.string.margin_xs') })
        }
        .alignRules({
          top: ComponentConst.bindBottom('verify_input'),
          start: ComponentConst.bindStart('verify_input'),
        })
        .margin({ top: $r('app.string.margin_xs') })
        .id('code_error_container')
      }
    }
    .backgroundColor(Color.White)
    .height(ComponentConst.AUTO_SIZE)
    .alignRules({
      top: ComponentConst.bindBottom('sign_in_code_bg'),
      left: ComponentConst.bindStart(),
      right: ComponentConst.bindEnd(),
    })
    .borderRadius({
      bottomLeft: ComponentConst.CARD_RADIUS_MIDDLE,
      bottomRight: ComponentConst.CARD_RADIUS_MIDDLE,
    })
    .margin({
      top: -10.5,
      left: 44,
      right: 44,
    })
    .padding({
      top: ComponentConst.CARD_PADDING_VERTICAL,
      bottom: ComponentConst.CARD_SPACE_LARGE,
    })
    .id('sign_input_container')
  }

  @Builder signInTipsBuilder() {
    Text($r('app.string.notes'))
      .fontSize($r('app.string.font_size_16'))
      .fontWeight(FontWeight.Bold)
      .alignRules({
        top: ComponentConst.bindBottom('sign_input_container'),
      })
      .margin({
        top: $r('app.string.margin_l'),
        left: 33,
      })
      .id('sign_in_tip_title')

    Text() {
      Span($r('app.string.sign_in_tip_1'))
      Span('\n\n')
      Span($r('app.string.sign_in_tip_2'))
    }
    .fontSize($r('app.string.font_size_12'))
    .fontColor($r('app.color.system_color_grey_60'))
    .alignRules({
      top: ComponentConst.bindBottom('sign_in_tip_title'),
      left: ComponentConst.bindStart('sign_in_tip_title'),
    })
    .margin({ top: $r('app.string.margin_xm') })
    .id('sign_in_tip_content')
  }

  verifyStateReset() {
    this.showErrorTips = false;
  }

  verifyCodeError() {
    this.verifyCode = '';
    this.showErrorTips = true;
    this._context.eventHub.emit(VerifyEventType.CODE_ERROR);
  }
}