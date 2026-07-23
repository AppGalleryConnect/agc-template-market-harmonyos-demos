import { Constants } from 'constant';
import { Commodity } from 'type';

@ComponentV2
export struct ContentCard {
  @Param @Require data: Commodity;

  build() {
    Column({ space: 8 }) {
      Image(this.data.banner)
        .width(Constants.FULL_SCREEN)
        .aspectRatio(1)
        .borderRadius(8)
        .objectFit(ImageFit.Cover);
      Text(this.data.goodsName)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'));
      Row({ space: 4 }) {
        Row() {
          Text('￥')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.warning'));
          Text(`${(this.data.retailPrice[0] * 100) / 100}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.warning'));
        }
        Text(`￥${(this.data.counterPrice[0] * 100) / 100}`)
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .decoration({ type: TextDecorationType.LineThrough });
      }
      .alignItems(VerticalAlign.Center);
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding(12);
  }
}