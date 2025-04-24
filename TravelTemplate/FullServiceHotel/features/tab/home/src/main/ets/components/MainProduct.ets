import { RouterMap, RouterModule } from 'commonlib';
import { ProductItem } from '../types';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct MainProduct {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      if (this.vm.productAd) {
        Image(this.vm.productAd)
          .width('100%')
          .borderRadius($r('app.string.border_radius_16'));
      }

      GridRow({
        columns: 2,
        gutter: { x: $r('app.string.margin_s'), y: $r('app.string.margin_s') },
        direction: GridRowDirection.Row,
      }) {
        ForEach(this.vm.productList, (item: ProductItem) => {
          GridCol() {
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(item.image)
                  .width('100%')
                  .aspectRatio(4 / 3)
                  .objectFit(ImageFit.Cover)
                  .draggable(false)
                  .borderRadius($r('app.string.border_radius_16'));
              };

              Text(item.label)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize($r('app.string.font_size_28'))
                .margin({ top: $r('app.string.margin_s') })
                .fontColor($r('app.color.font_color_level1'));
              Row() {
                Text('￥')
                  .fontSize($r('app.string.font_size_16'))
                  .fontColor($r('app.color.system_color_highlight'));
                Text(item.discountedPrice)
                  .fontSize($r('app.string.font_size_28'))
                  .fontColor($r('app.color.system_color_highlight'))
                  .margin({ right: $r('app.string.margin_xs') });
                Text('￥' + item.originalPrice)
                  .fontSize($r('app.string.font_size_16'))
                  .fontColor($r('app.color.font_color_level2'))
                  .decoration({ type: TextDecorationType.LineThrough });
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({
                top: $r('app.string.margin_xs'),
              });
            }
            .width('100%')
            .backgroundColor($r('app.color.system_color_background_white'))
            .borderRadius($r('app.string.border_radius_16'))
            .padding($r('app.string.padding_s'))
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_INFO, param: Number(item.id) });
            });
          };
        }, (item: ProductItem) => JSON.stringify(item));
      }
      .padding({
        top: $r('app.string.margin_s'),
      });
    };
  }
}