import { hilog } from '@kit.PerformanceAnalysisKit';
import { loginComponentManager } from '@kit.AccountKit';

@CustomDialog
export struct AgreementDialog {
  logTag: string = 'AgreementDialog';
  domainId: number = 0x0000;
  dialogController?: CustomDialogController;
  cancel: () => void = () => {};
  confirm: () => void = () => {};
  privacyText: loginComponentManager.PrivacyText[] = [];
  pathStack?: NavPathStack

  @Builder
  bulidSpan(content: ResourceStr, fontColor: Resource | string, fontFamily: Resource, fontWight: number,
    textIndex: number, focusable?: boolean, focusOnTouch?: boolean) {
    Span(content)
      .fontSize($r('sys.float.ohos_id_text_size_body1'))
      .fontColor(fontColor)
      .fontFamily(fontFamily)
      .fontWeight(fontWight)
      .focusable(focusable)
      .focusOnTouch(focusOnTouch)
      .onClick(() => {
        switch (textIndex) {
          case 1:
            this.dialogController?.close()
            this.pathStack?.pushPathByName('TermsOfServicePage', null);
            break;
          case 3:
            this.dialogController?.close()
            this.pathStack?.pushPathByName('PrivacyPolicyPage', null);
            break;
          default:
            break;
        }
      })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.user_agreemenet_and_privacy_policy'))
          .id('loginPanel_agreement_dialog_privacy_title')
          .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
          .minFontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 56, maxWidth: 400 })
      .margin({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Row() {
        Text() {
          if (this.privacyText && this.privacyText.length >= 5) {
            this.bulidSpan(this.privacyText[0].text, $r('sys.color.ohos_id_color_text_primary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 0)

            this.bulidSpan(this.privacyText[1].text, '#CE0E2D',
              $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 1, true, true)


            this.bulidSpan(this.privacyText[2].text, $r('sys.color.ohos_id_color_text_primary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 2)

            this.bulidSpan(this.privacyText[3].text, '#CE0E2D',
              $r('sys.string.ohos_id_text_font_family_medium'), FontWeight.Medium, 3, true, true)

            this.bulidSpan(this.privacyText[4].text, $r('sys.color.ohos_id_color_text_primary'),
              $r('sys.string.ohos_id_text_font_family_regular'), FontWeight.Regular, 4)
          }
        }
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(10)
        .textAlign(TextAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
        .padding({ left: 24, right: 24 })
      }.width('100%')

      Flex({
        direction: FlexDirection.Row
      }) {
        Button($r('app.string.cancel'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('app.color.font_emphasize'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .backgroundColor(Color.Transparent)
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog cancel');
            this.cancel();
          })

        Button($r('app.string.agree_and_sign_in'),
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_dialog_huawei_id_login_btn')
          .fontColor($r('app.color.font_emphasize'))
          .backgroundColor('#FFFFFF')
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog confirm');
            this.confirm();
          })
      }
      .margin({
        top: 8,
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        bottom: 16
      })
    }
    .padding({
      left: 16,
      right: 16
    })
  }
}