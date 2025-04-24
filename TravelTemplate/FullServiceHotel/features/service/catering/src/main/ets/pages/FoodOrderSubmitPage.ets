import { CommonButton, CommonDivider, CommonHeader } from 'componentlib';
import { MealOrderVM } from '../viewmodels/MealOrderVM';
import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { MealDetailCard } from '../components/MealDetailCard';

@ComponentV2
export default struct FoodOrderSubmitPage {
  mealOrderVm: MealOrderVM = MealOrderVM.instance;

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Start,
      }) {
        CommonHeader({
          title: this.mealOrderVm.mealRequest?.shopName ?? '',
        });
        Scroll() {
          Column() {
            this.packageInfoBuilder();

            CommonDivider({ strokeWidth: 5 });

            MealDetailCard({
              foodInfo: this.mealOrderVm.foodInfo,
            });
          }
          .justifyContent(FlexAlign.Start);
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width($r('app.string.width_percent_full'));

        Blank();

        this.bottomButtonBuilder();
      }
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .height($r('app.string.height_percent_full'));
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.mealOrderVm.resetFoodCount();
    });

  }

  @Builder
  packageInfoBuilder() {
    Row() {
      Image(this.mealOrderVm.foodInfo?.coverUrl)
        .height(60)
        .aspectRatio(16 / 9)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.border_radius_8'))
        .margin({ right: $r('app.string.margin_s') });

      Column() {
        Text(this.mealOrderVm.foodInfo?.mealPackageName)
          .fontSize($r('app.string.font_size_32'))
          .fontWeight(500)
          .fontColor($r('app.color.font_color_level1'));
        PromoPriceLabel({
          promoPrice: this.mealOrderVm.foodInfo?.promoPrice,
          originalPrice: this.mealOrderVm.foodInfo?.originalPrice,
          promoFontSize: $r('app.string.font_size_32'),
          originalFontSize: $r('app.string.font_size_20'),
        });
      }
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      Row() {
        Image($r('app.media.icon_circle_subtract'))
          .height($r('app.integer.icon_size_20'))
          .fillColor(this.mealOrderVm.foodCount <= 1 ?
          $r('app.color.font_color_level3') :
          $r('app.color.font_color_level1'))
          .onClick(() => {
            this.mealOrderVm.handleFoodCount(false);
          });
        Text(this.mealOrderVm.foodCount.toString())
          .fontSize($r('app.string.font_size_32'))
          .margin({
            left: $r('app.string.margin_m'),
            right: $r('app.string.margin_m'),
          });
        Image($r('app.media.icon_circle_add'))
          .height($r('app.integer.icon_size_20'))
          .fillColor(this.mealOrderVm.foodCount >= this.mealOrderVm.MAX_FOOD_COUNT ?
          $r('app.color.font_color_level3') :
          $r('app.color.font_color_level1'))
          .onClick(() => {
            this.mealOrderVm.handleFoodCount();
          });
      }
      .height(60)
      .alignItems(VerticalAlign.Bottom);
    }
    .backgroundColor($r('app.color.system_color_background_white'))
    .padding($r('app.string.padding_s'))
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      Column() {
        PromoPriceLabel({
          promoPrice: Number(this.mealOrderVm.foodInfo?.promoPrice ?? 0) * this.mealOrderVm.foodCount,
          originalPrice: Number(this.mealOrderVm.foodInfo?.originalPrice ?? 0) * this.mealOrderVm.foodCount,
          promoFontSize: $r('app.string.font_size_40'),
          originalFontSize: $r('app.string.font_size_24'),
        });

        Text('总额')
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level2'))
          .margin({ top: $r('app.string.margin_xs') });
      }
      .alignItems(HorizontalAlign.Start);

      CommonButton({
        title: '提交订单',
        fullWidth: false,
        handleClick: () => {
          this.mealOrderVm.prepayMeal();
        },
      });
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.string.padding_m'),
      right: $r('app.string.padding_s'),
      top: $r('app.string.padding_m'),
    })
    .borderWidth({ top: 1 })
    .borderColor($r('app.color.system_color_grey_level2'))
    .backgroundColor($r('app.color.system_color_background_white'));
  }
}

@Builder
export function foodOrderSubmitPageBuilder() {
  FoodOrderSubmitPage();
}