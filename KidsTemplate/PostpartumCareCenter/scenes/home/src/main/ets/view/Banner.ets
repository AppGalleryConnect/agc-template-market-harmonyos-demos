import { BANNER_LIST } from '../constants/Constants';

@Preview
@ComponentV2
export struct Banner {
  build() {
    Swiper() {
      ForEach(BANNER_LIST, (item: Resource) => {
        Image(item)
          .objectFit(ImageFit.Fill)
          .width('100%')
          .height(246)
          .borderRadius($r('app.string.border_radius_16'))
          .padding({ right: $r('app.string.padding_16'), left: $r('app.string.padding_16') })
      }, (item: Resource) => JSON.stringify(item));
    }
    .indicator(
      Indicator.dot()
        .selectedColor('#FFFFFF')
        .selectedItemWidth(12)
        .selectedItemHeight(8)
        .itemWidth(8)
        .itemHeight(8)
        .color('rgba(0,0,0,0.10)')
    )
    .clip(false)
    .autoPlay(true)
    .loop(true)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}