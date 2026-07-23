import { ImageShowModel } from '../model/PageParams';

@ComponentV2
export struct IconAndTextView {
  @Param @Require barItem: ImageShowModel;
  @Event clickAction: () => void;

  build() {
    Column({space:4}) {
      Image(this.barItem.imageSource)
        .width(48)
        .height(48)
        .borderRadius(8)
        .shadow({
          radius: 12,
          offsetY: 4,
          color: 'rgba(0, 0, 0, 0.1)'
        })

      Text(this.barItem.text)
        .fontWeight(FontWeight.Regular)
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
    }
    .onClick(() => {
      this.clickAction?.()
    })
  }
}