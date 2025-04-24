import { CommonBanner, CommonScroll } from 'componentlib';

import { MappedMealPackage, MappedRestaurant } from '../models/MappedRestaurant';
import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { RestaurantListPageVM } from '../viewmodels/RestaurantListPageVM';

@ComponentV2
struct RestaurantListPage {
  vm: RestaurantListPageVM = RestaurantListPageVM.instance;

  build() {
    NavDestination() {
      Column() {
        CommonScroll({ title: '餐厅列表' }) {
          Column() {
            CommonBanner({ x: 4, y: 3, covers: [this.vm.topBanner] });

            ForEach(this.vm.restaurantList, (restaurant: MappedRestaurant) => {
              this.restaurantCardBuilder(restaurant);
            }, (item: MappedRestaurant) => JSON.stringify(item));
          };
        };
      }
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .width($r('app.string.width_percent_full'))
      .height($r('app.string.height_percent_full'));
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  restaurantCardBuilder(restaurant: MappedRestaurant) {
    Column() {
      this.restaurantHeaderBuilder(restaurant);

      List() {
        ForEach(restaurant.mappedMealPackageList, (mealPackage: MappedMealPackage) => {
          ListItem() {
            this.mealCardBuilder(mealPackage);
          };
        }, (item: MappedMealPackage) => JSON.stringify(item));
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .height('auto')
      .width($r('app.string.width_percent_full'))
      .margin({ top: $r('app.string.margin_s') });
    }
    .padding({
      left: $r('app.string.padding_s'),
      right: $r('app.string.padding_s'),
      top: $r('app.string.padding_m'),
      bottom: $r('app.string.padding_m'),
    })
    .margin($r('app.string.margin_s'))
    .backgroundColor($r('app.color.system_color_background_white'))
    .borderRadius($r('app.string.border_radius_8'));
  }

  @Builder
  restaurantHeaderBuilder(restaurant: MappedRestaurant) {
    Row() {
      Image(restaurant.cover)
        .height($r('app.integer.icon_size_32'))
        .aspectRatio(1)
        .borderRadius($r('app.string.border_radius_8'));
      Column() {
        Row() {
          Text(restaurant.name)
            .fontSize($r('app.string.font_size_32'))
            .fontColor($r('app.color.font_color_level1'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1);
          Blank();
          Text(restaurant.distanceInMeters)
            .fontSize($r('app.string.font_size_24'))
            .fontColor('#FF191919');

        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text(restaurant.address)
            .fontSize($r('app.string.font_size_24'))
            .fontColor($r('app.color.font_color_level2'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1);
          Text('月销' + (restaurant.monthlyTotalSales ?? '--'))
            .fontSize($r('app.string.font_size_24'))
            .fontColor($r('app.color.font_color_level2'));

        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .layoutWeight(1)
      .height('85lpx')
      .padding({ left: $r('app.string.padding_xs') })
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .height('auto')
    .onClick(() => {
      this.vm.jumpToRestaurantPage(restaurant.shopId);
    });
  }

  @Builder
  mealCardBuilder(mealPackage: MappedMealPackage) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(mealPackage.coverUrl)
          .width('100%')
          .aspectRatio(4 / 3)
          .borderRadius($r('app.string.border_radius_8'));
        Text('月销' + (mealPackage.monthlySales ? mealPackage.monthlySales : '--'))
          .fontSize($r('app.string.font_size_16'))
          .fontWeight(300)
          .borderRadius($r('app.string.border_radius_8'))
          .fontColor($r('app.color.font_color_level1_invert'))
          .backgroundColor($r('app.color.system_color_background_transparent_black'))
          .padding($r('app.string.padding_xs'))
          .margin({ left: $r('app.string.margin_xs'), bottom: $r('app.string.margin_xs') });
      };

      Text(mealPackage.name)
        .fontSize($r('app.string.font_size_28'))
        .margin({
          top: $r('app.string.margin_s'),
          bottom: $r('app.string.margin_xs'),
        })
        .fontColor($r('app.color.font_color_level1'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width($r('app.string.width_percent_75'));
      PromoPriceLabel({
        promoPrice: mealPackage.promoPrice,
        promoFontSize: $r('app.string.font_size_32'),
        originalPrice: mealPackage.originalPrice,
        originalFontSize: $r('app.string.font_size_24'),
      });
    }
    .alignItems(HorizontalAlign.Start)
    .width($r('app.string.width_percent_40'))
    .justifyContent(FlexAlign.Start)
    .margin({ right: $r('app.string.margin_s') })
    .onClick(() => {
      this.vm.jumpToFoodInfoPage(mealPackage.id);
    });
  }
}

@Builder
export function restaurantListPageBuilder() {
  RestaurantListPage();
}