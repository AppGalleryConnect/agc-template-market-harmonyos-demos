import { MeasureText } from '@kit.ArkUI';
import { SearchType } from '../constants/CommonConstants';

@ComponentV2
export struct AdaptiveButton {
  @Param @Require item: SearchType;
  @Param @Require clickIndex: number;
  @Event invoke: (index: number) => void = () => {
  }

  build() {
    Column() {
      Text(this.item.title)
        .fontSize($r('app.float.font_size_14'))
        .fontColor(Color.Black)
        .height('100%')
    }
    .height(30)
    .width(px2vp(MeasureText.measureText({
      textContent: this.item.title,
      fontSize: $r('app.float.font_size_14')
    })) + 30)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(16)
    .backgroundColor(this.clickIndex === this.item.index ? $r('app.color.button_blue_light') :
    $r('app.color.button_gray'))
    .onClick(() => {
      this.invoke(this.item.index)
    })
  }
}