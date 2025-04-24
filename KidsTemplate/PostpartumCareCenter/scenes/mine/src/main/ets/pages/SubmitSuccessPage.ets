import { Logger } from '@ohos_agcit/postpartum_care_center_utils';

@Builder
export function SubmitSuccessPageBuilder() {
  SubmitSuccessPage();
}

@Preview
@ComponentV2
export struct SubmitSuccessPage {

  aboutToAppear(): void {
    Logger.debug('aaa');
    Logger.debug('aaa');
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.success_flag'))
          .objectFit(ImageFit.Contain)
          .width(48)
          .height(48)
          .margin({
            top: ($r('app.string.padding_48'))
          })

        Text('提交成功')
          .width('100%')
          .fontSize($r('app.string.font_size_16'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,0.90)')
          .lineHeight(22)
          .margin({
            top: ($r('app.string.padding_12'))
          })
          .textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

}