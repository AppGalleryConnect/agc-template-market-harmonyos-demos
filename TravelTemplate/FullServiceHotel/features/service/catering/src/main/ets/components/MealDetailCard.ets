import { CommonDivider } from 'componentlib';
import { MappedFood, MappedFoodInfo, MappedFoodInfoItem } from '../models/MappedFoodInfo';

@ComponentV2
export struct MealDetailCard {
  @Require @Param foodInfo: MappedFoodInfo | undefined;

  build() {
    Column() {
      Text('团购详情')
        .fontSize($r('app.string.font_size_32'))
        .fontColor($r('app.color.font_color_level1'));
      Column() {
        ForEach(this.foodInfo?.items, (item: MappedFoodInfoItem) => {
          Text(item.type)
            .fontSize($r('app.string.font_size_28'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ top: $r('app.string.margin_s') });
          ForEach(item.foods, (food: MappedFood) => {
            this.foodItemBuilder(food.name, food.description, '￥' + food.price);
          }, (item: MappedFood) => JSON.stringify(item));
        }, (item: MappedFoodInfoItem) => JSON.stringify(item));
      }
      .padding({
        left: $r('app.string.padding_xs'),
        right: $r('app.string.padding_xs'),
        top: $r('app.string.padding_s'),
        bottom: $r('app.string.padding_s'),
      })
      .backgroundColor($r('app.color.system_color_background_white'))
      .alignItems(HorizontalAlign.Start);

      CommonDivider()
        .margin({ bottom: $r('app.string.margin_s') });

      if (this.foodInfo?.usageRule) {
        Text('使用须知')
          .fontSize($r('app.string.font_size_32'))
          .fontColor($r('app.color.font_color_level1'));

        Text(this.foodInfo.usageRule)
          .fontSize($r('app.string.font_size_28'))
          .fontColor($r('app.color.font_color_level1'))
          .lineHeight('42lpx')
          .margin($r('app.string.margin_s'));
      }

    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding($r('app.string.padding_s'))
    .width($r('app.string.width_percent_full'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  foodItemBuilder(name: string, count: string, price: string) {
    Row() {
      Row() {
        Text('·')
          .fontSize($r('app.string.font_size_36'))
          .margin({
            left: $r('app.string.margin_s'),
            right: $r('app.string.margin_s'),
          });

        Text(name)
          .labelStyle();
      }
      .width($r('app.string.width_percent_75'))
      .alignItems(VerticalAlign.Top);

      Row() {
        Text(count + '份')
          .labelStyle()
          .layoutWeight(1);
        Text(price)
          .labelStyle();
      }
      .width($r('app.string.width_percent_25'))
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width($r('app.string.width_percent_full'))
    .margin({ top: $r('app.string.margin_s') })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@Extend(Text)
function labelStyle() {
  .fontSize($r('app.string.font_size_24'))
  .fontColor($r('app.color.font_color_level2'));
}