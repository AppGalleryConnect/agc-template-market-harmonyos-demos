import { ProductCardItem, ProductCardLabel } from 'lib_network';
import { LabelPresetType } from '../commons/Enums';

@ReusableV2
@ComponentV2
export struct GridProductCardView {
  @Param @Require
  product: ProductCardItem

  build() {
    Column() {
      Image(this.product.banner);
      Column({ space: 8 }) {
        buildTitle(this.product.title);
        buildLabel(this.product.label);
        buildPromotion(this.product.promotion);
        buildPrice(this.product.price, this.product.dashPrice);
      }
      .padding(8)
      .alignItems(HorizontalAlign.Start);
    }
    .borderRadius(16)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color_primary'));
  }
}

@ReusableV2
@ComponentV2
export struct ListProductCardView {
  @Param @Require
  product: ProductCardItem

  build() {
    Row() {
      Image(this.product.banner)
        .width(100)
        .height(100)
        .borderRadius(8)

      Column({ space: 4 }) {
        buildTitle(this.product.title);
        buildLabel(this.product.label);
        buildPromotion(this.product.promotion);
        buildPrice(this.product.price, this.product.dashPrice);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding(8)
      .height('100%');
    }
    .height(100)
    .clip(true)
    .borderRadius(16)
    .backgroundColor($r('app.color.background_color_primary'));
  }
}

@Builder
function buildTitle(title: string, tag?: string) {
  Row() {
    Text() {
      if (tag) {
        ContainerSpan() {
          Span(tag)
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontSize($r('app.float.font_size_10'))
            .lineHeight(14)
        }
        .textBackgroundStyle({
          color: $r('app.color.theme_color'),
          radius: $r('app.float.border_radius_xs'),
        })

        Span(' ')
      }
      Span(title)
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
        .fontSize(14)
    }
    .maxLines(2)
    .textOverflow({ overflow: TextOverflow.Ellipsis });
  }
}

@Builder
function buildLabel(labels: ProductCardLabel[]) {
  if (labels.length) {
    Text() {
      ForEach(labels, (label: ProductCardLabel, index: number) => {
        if (label.preset === LabelPresetType.PRIMARY) {
          Span(label.data).fontColor($r('app.color.label_color_primary'));
        } else if (label.preset === LabelPresetType.SECONDARY) {
          Span(label.data).fontColor($r('app.color.label_color_secondary'));
        }
        if (index < labels.length - 1) {
          Span(' | ').fontColor($r('app.color.font_color_level3'));
        }
      }, (label: ProductCardLabel, index: number) => index + label.data);
    }
    .fontSize(12)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis });
  }
}

@Builder
function buildPromotion(promotions: string[]) {
  if (promotions.length) {
    Flex() {
      ForEach(promotions, (promotion: string) => {
        Row() {
          Text(promotion)
            .fontSize(8)
            .fontColor($r('app.color.theme_color'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .borderWidth(1)
        .borderColor($r('app.color.theme_color'))
        .borderRadius(2)
        .padding(2)
        .flexShrink(1);
      }, (promotion: string, index: number) => index + promotion);
    };
  }
}

@Builder
function buildPrice(price: number, dashPrice?: number) {
  Text() {
    Span('¥');
    Span(price.toString()).fontSize(16);
    if (dashPrice) {
      Span(' ').letterSpacing(2);
      Span('¥' + dashPrice)
        .fontColor($r('app.color.font_color_level3'))
        .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.font_color_level3') });
    }
  }
  .fontSize(12)
  .fontColor($r('app.color.theme_color'))
  .fontWeight(FontWeight.Medium);
}
