import { OrderSkuItem } from 'lib_network';

@ComponentV2
export struct OrderItemCard {
  @Param
  sku: OrderSkuItem | undefined = undefined;

  build() {
    if (this.sku) {
      Row() {
        Image(this.sku.banner)
          .width(80)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius($r('app.float.border_radius_s'))
          .margin({ right: 12 })
          .backgroundColor($r('app.color.icon_color_grey'));
        Column() {
          Text(this.sku.title)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium);
          Text('规格：' + this.sku.skuDesc).textSecondaryStyle();
          Text('数量：' + this.sku.count).textSecondaryStyle();
          Blank();
          Text(this.sku.serviceDesc).textThirdlyStyle();
        }
        .layoutWeight(1)
        .margin({ right: 16 })
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start);

        Column() {
          Text() {
            Span('¥').fontSize($r('app.float.font_size_12'));
            Span(this.sku.price.toString());
          }
          .fontColor($r('app.color.theme_color'))
          .fontWeight(FontWeight.Medium);

          Text() {
            Span('¥');
            Span(this.sku.dashPrice.toString());
          }
          .decoration({
            type: TextDecorationType.LineThrough,
            color: $r('app.color.font_color_level3'),
          })
          .fontSize($r('app.float.font_size_10'))
          .fontColor($r('app.color.font_color_level3'))
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 });
        }
        .height('100%')
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height(80)
      .margin({ bottom: 16 });
    }

  }
}

@Extend(Text)
function textSecondaryStyle() {
  .fontColor($r('app.color.font_color_level3'))
  .fontSize($r('app.float.font_size_12'))
  .margin({ top: 4 });
}

@Extend(Text)
function textThirdlyStyle() {
  .fontColor($r('app.color.font_color_level3'))
  .fontSize($r('app.float.font_size_10'));
}