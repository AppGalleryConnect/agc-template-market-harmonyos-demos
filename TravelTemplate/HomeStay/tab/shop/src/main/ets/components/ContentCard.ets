import { Constants } from 'constant';
import { Commodity } from 'type';

@ComponentV2
export struct ContentCard {
  @Param @Require data: Commodity;

  build() {
    Column({ space: 8 }) {
      Image(this.data.banner)
        .objectFit(ImageFit.Fill)
        .autoResize(true)
        .syncLoad(true)
        .borderRadius(8);
      Text(this.data.goodsName)
        .fontSize(12)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Row() {
        Text(`￥${(this.data.retailPrice[0] * 100) / 100}`)
          .fontSize(12)
          .fontColor(Color.Red)
          .fontWeight(600);
        Text(`￥${(this.data.counterPrice[0] * 100) / 100}`)
          .fontSize(12)
          .fontColor($r('app.color.old_price_font_color'))
          .margin({ left: 4 })
          .fontColor(Color.Gray)
          .decoration({ type: TextDecorationType.LineThrough, color: Color.Gray });
      };
    }
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_SCREEN)
    .backgroundColor(Color.White)
    .borderRadius(8);
  }
}