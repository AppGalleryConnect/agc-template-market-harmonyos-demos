import { CommonBanner, CommonScroll } from 'componentlib';

import { MappedMealPackage } from '../models/MappedRestaurant';
import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { RestaurantPageVM } from '../viewmodels/RestaurantPageVM';

@ComponentV2
struct RestaurantPage {
  vm: RestaurantPageVM = RestaurantPageVM.instance;

  build() {
    NavDestination() {
      CommonScroll({ title: '餐厅详情' }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Column() {
            CommonBanner({
              x: 4,
              y: 3,
              covers: this.vm.restaurant?.banners ?? [''],
            });
            this.restaurantCardBuilder();
            this.mealPackageListBuilder();
          };
        }
        .height($r('app.string.height_percent_full'))
        .backgroundColor($r('app.color.system_color_background_auxiliary'));
      };
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  restaurantCardBuilder() {
    Row() {
      Image(this.vm.restaurant?.cover)
        .width(60)
        .height(60)
        .margin({right:$r('app.string.margin_s')})
        .borderRadius($r('app.string.border_radius_8'))
      Column() {
        Row() {
          Text(this.vm.restaurant?.name)
            .fontSize($r('app.string.font_size_32'))
            .fontColor($r('app.color.font_color_level1'))
            .layoutWeight(1);
          Text(this.vm.restaurant?.distanceInMeters)
            .greyTextStyle();
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);

        Row() {
          Text(this.vm.restaurant?.address).greyTextStyle().layoutWeight(1);
          Text('月销' + this.vm.restaurant?.monthlyTotalSales ?? '--').greyTextStyle();
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);

        Row() {
          Text(this.vm.restaurant?.notice).greyTextStyle().layoutWeight(1);
          Row() {
            Image($r('app.media.icon_phone_write'))
              .height($r('app.integer.icon_size_12'))
              .fillColor($r('app.color.icon_color_highlight'));
            Text('联系商家').greyTextStyle().fontColor($r('app.color.font_color_link'));
          }
          .onClick(() => {
            this.vm.makeCall();
          });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);
      }
      .layoutWeight(1)
      .height($r('app.string.height_percent_full'))
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .height(90)
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.system_color_background_white'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding($r('app.string.padding_s'),
    )
    .margin({ bottom: $r('app.string.margin_s') });
  }

  @Builder
  mealPackageListBuilder() {
    Grid() {
      ForEach(this.vm.restaurant?.mappedMealPackageList, (mealPackage: MappedMealPackage) => {
        GridItem() {
          Column() {
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(mealPackage.coverUrl)
                  .width($r('app.string.width_percent_full'))
                  .aspectRatio(4 / 3)
                  .objectFit(ImageFit.Cover)
                  .borderRadius($r('app.string.border_radius_8'));
                Text('月销' + (mealPackage.monthlySales ?? '--'))
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
                .margin({ top: $r('app.string.margin_s') })
                .fontColor($r('app.color.font_color_level1'));
              PromoPriceLabel({
                promoPrice: mealPackage.promoPrice,
                originalPrice: mealPackage.originalPrice,
                promoFontSize: $r('app.string.font_size_32'),
                originalFontSize: $r('app.string.font_size_24'),
              });
            }
            .padding($r('app.string.padding_s'))
            .onClick(() => {
              this.vm.jumpToFoodInfoPage(mealPackage.id);
            })
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start);
          }
          .width('100%')
          .backgroundColor('#FFFFFFFF')
          .borderRadius(8);
        };
      }, (item: MappedMealPackage) => JSON.stringify(item));
    }
    .width('100%')
    .padding({ left: $r('app.string.padding_s'), right: $r('app.string.padding_s') })
    .columnsTemplate('1fr 1fr')
    .columnsGap($r('app.string.margin_s'))
    .rowsGap($r('app.string.margin_s'));
  }
}

@Builder
export function restaurantPageBuilder() {
  RestaurantPage();
}

@Extend(Text)
function greyTextStyle() {
  .fontSize($r('app.string.font_size_24'))
  .fontColor($r('app.color.font_color_level2'));
}