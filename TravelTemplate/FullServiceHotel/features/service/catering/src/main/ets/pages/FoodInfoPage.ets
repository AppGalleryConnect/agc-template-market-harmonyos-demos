import { CommonButton, CommonDivider, CommonBanner, CommonScroll } from 'componentlib';

import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { RouterMap, RouterModule } from 'commonlib';
import { MealDetailCard } from '../components/MealDetailCard';
import { FoodInfoPageVM } from '../viewmodels/FoodInfoPageVM';

@ComponentV2
struct FoodInfoPage {
  vm: FoodInfoPageVM = FoodInfoPageVM.instance;

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
      }) {
        CommonScroll({ title: '套餐详情' }) {
          Column() {
            CommonBanner({ x: 4, y: 3, covers: [this.vm.foodInfo?.coverUrl ?? ''] });

            this.mealHeaderBuilder();

            CommonDivider({ strokeWidth: 5 });

            MealDetailCard({
              foodInfo: this.vm.foodInfo,
            });
          }
          .width($r('app.string.width_percent_full'));
        };

        Blank();

        Row() {
          CommonButton({
            title: '立即团购',
            handleClick: () => {
              RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_ORDER });
            },
          });
        }
        .padding({
          left: $r('app.string.padding_s'),
          right: $r('app.string.padding_s'),
          top: $r('app.string.padding_m'),
        })
        .borderWidth({ top: 1 })
        .borderColor($r('app.color.system_color_grey_level2'))
        .backgroundColor($r('app.color.system_color_background_white'));
      }
      .height($r('app.string.height_percent_full'));
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  mealHeaderBuilder() {
    Column() {
      Row() {
        PromoPriceLabel({
          promoPrice: this.vm.foodInfo?.promoPrice,
          originalPrice: this.vm.foodInfo?.originalPrice,
        });

        Text('月销' + (this.vm.foodInfo?.monthlySales ?? '--'))
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level2'));
        
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom);

      Row() {
        Text(this.vm.foodInfo?.mealPackageName)
          .fontSize($r('app.string.font_size_36'))
          .fontColor($r('app.color.font_color_level1'));
      }
      .width($r('app.string.width_percent_full'))
      .margin({
        top: $r('app.string.margin_s'),
        bottom: $r('app.string.margin_s'),
      })
      .justifyContent(FlexAlign.Start);
    }
    .padding($r('app.string.padding_s'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.system_color_background_white'));
  }
}

@Builder
export function foodInfoPageBuilder() {
  FoodInfoPage();
}