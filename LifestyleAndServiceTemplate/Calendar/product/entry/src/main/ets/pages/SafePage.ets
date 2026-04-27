import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UserState } from 'common';

@Entry
@ComponentV2
struct SafePage {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;

  build() {
    Column() {
      Image($r('app.media.foreground'))
        .width(72).height(72)
        .margin({ top: 136, bottom: 24 })
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
      Text('日历模板提供日历、黄历查看等相关功能。')
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .lineHeight(19)
        .margin({ top: 6 })

      Blank()

      Image($r('app.media.ic_safe'))
        .height(18)
        .height(22)
        .margin({ bottom: 16 })

      Text() {
        Span($r('app.string.safe_desc1_str1'))
          .fontSize(10)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(14)
        Span($r('app.string.safe_desc1_str2'))
          .fontSize(10)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(14)
        Span($r('app.string.safe_desc1_str3'))
          .fontSize(10)
          .lineHeight(14)
        Span($r('app.string.safe_desc1_str4'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .lineHeight(14)
        Span($r('app.string.safe_desc1_str5'))
          .fontSize(10)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(14)
        Span($r('app.string.safe_desc1_str6'))
          .fontSize(10)
          .fontColor($r('app.color.theme_blue_color'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(14)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/PrivacyPage' })
          })
        Span($r('app.string.safe_desc1_str7'))
          .fontSize(10)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(14)
      }
      .width('100%')

      Text($r('app.string.safe_desc2'))
        .fontSize(10)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .lineHeight(14)
        .width('100%')
        .margin({ top: 5 })

      Row({ space: 12 }) {
        Button($r('app.string.button_cancel'))
          .backgroundColor($r('app.color.safe_cancel_button_bg'))
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .onClick(() => {
            let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
            context.terminateSelf();
          })
        Button($r('app.string.button_agree'))
          .backgroundColor($r('app.color.theme_blue_color'))
          .fontColor($r('sys.color.font_on_primary'))
          .layoutWeight(1)
          .onClick(() => {
            this.userState.isAgreedPrivacy = true
            PersistenceV2.save(UserState)
            this.getUIContext().getRouter().replaceUrl({ url: 'pages/SplashPage' })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 24, bottom: 45 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}