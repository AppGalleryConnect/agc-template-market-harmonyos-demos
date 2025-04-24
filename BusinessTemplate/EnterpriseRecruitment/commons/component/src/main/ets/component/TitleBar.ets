import { CommonConstants } from '../constants/CommonConstants';

@ComponentV2
export struct TitleBar {
  @Param text: string | Resource = '';

  build() {
    Row() {
      Text(this.text)
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(CommonConstants.FONT_WEIGHT_800)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}