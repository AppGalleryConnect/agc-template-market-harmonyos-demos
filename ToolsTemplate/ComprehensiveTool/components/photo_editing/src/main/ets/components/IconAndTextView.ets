import { ImageShowModel } from '../model/PageParams';

@ComponentV2
export struct IconAndTextView {
  @Param @Require barItem: ImageShowModel

  build() {
    Column() {
      Image(this.barItem.imageSource)
        .width(55)
        .height(55)

      Text(this.barItem.text)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Regular)
        .fontSize(14)
        .fontColor($r('sys.color.black'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }
}