import { Constants } from 'constant';
import { Commodity } from 'type';
import { formatPriceToNumber } from 'util';

@ComponentV2
export struct Basic {
  private swiperController: SwiperController = new SwiperController();
  @Param @Require commodity: Commodity;
  @Event onSpecClick: () => void = () => {};

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.commodity.detailImages, (item: ResourceStr) => {
          Image(item).objectFit(ImageFit.Cover).width(Constants.FULL_SCREEN).height(360);
        }, (item: ResourceStr) => item.toString());
      }.indicator(new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .color($r('app.color.common_bg_color'))
        .selectedColor($r('sys.color.comp_background_emphasize')));

      Column() {
        Row() {
          ForEach(this.commodity.detailImages, (item: ResourceStr, index: number) => {
            Image(item).width(40).height(40).borderRadius(4).objectFit(ImageFit.Cover)
              .border({ width: 1, color: $r('sys.color.comp_background_emphasize') })
              .onClick(() => {
                this.swiperController.changeIndex(index);
              });
          }, (item: ResourceStr) => item.toString());

          Blank().layoutWeight(1);

          Row() {
            Text('选择规格')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
            Image($r('app.media.icon_direction_right_gray'))
              .width(12)
              .height(24)
              .margin({ left: 4 })
          }.onClick(() => {
            this.onSpecClick();
          })
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 12 })

        Row() {
          Text() {
            Span('￥').fontSize(12).fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.warning'))
            Span(`${formatPriceToNumber(this.commodity.retailPrice[0])}`).fontSize(24).fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.warning'))
          }
          Text(`￥${formatPriceToNumber(this.commodity.counterPrice[0])}`)
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 8 })
          Blank().layoutWeight(1)
          Text(`已售 ${this.commodity.count}+`)
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 12 })

        Text(`${this.commodity.goodsName}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 8 })
          .maxLines(2)

        Row() {
          Image($r('app.media.icon_delivery')).width(14).height(14)
          Text('48小时内发货\n免运费 | 江西赣州发货')
            .fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ left: 8 })
            .lineHeight(16)
          Blank().layoutWeight(1)
          Image($r('app.media.icon_direction_right_gray')).width(10).height(16)
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Top)
        .margin({ top: 12 })

        Row() {
          Image($r('app.media.icon_care')).width(14).height(14)
          Text('运费险 | 7天无理由')
            .fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ left: 8 })
            .lineHeight(16)
          Blank().layoutWeight(1)
          Image($r('app.media.icon_direction_right_gray')).width(10).height(16)
        }
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 12 })
      }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start).padding({ left: 12, right: 12 });
    };
  }
}