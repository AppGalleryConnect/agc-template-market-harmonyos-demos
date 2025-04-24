import { FormatUtil } from 'commonlib';
import { DinnerMenu, DishItem, GetMealDetailResp } from 'network';

import { MappedFood, MappedFoodInfo, MappedFoodInfoItem } from '../models/MappedFoodInfo';

export function mapFoodInfoResponse(foodInfo: GetMealDetailResp): MappedFoodInfo {
  let mappedFoodInfo: MappedFoodInfo = {
    mealPackageName: foodInfo.packageName ?? '',
    originalPrice: foodInfo.price ?? '',
    promoPrice: foodInfo.discountedPrice ?? '--',
    monthlySales: FormatUtil.salesDisplay(foodInfo.monthlySells ?? 0),
    coverUrl: FormatUtil.getImgResource(foodInfo.images),
    items: convertDinnerMenu(foodInfo.dinnerMenus),
    usageRule:foodInfo.usageRule,
  };
  return mappedFoodInfo;
}

function convertDinnerMenu(dinnerMenus: DinnerMenu[]): MappedFoodInfoItem[] {
  let items: MappedFoodInfoItem[] = [];
  for (let dinnerMenu of dinnerMenus) {
    let dishes: DishItem[] = dinnerMenu.dishes;
    let foods: MappedFood[] = [];
    for (let dish of dishes) {
      foods.push({
        name: dish.name,
        price: !dish.price || dish.price === '' ? '---' : dish.price,
        description: dish.showNumber,
      });
    }
    let item: MappedFoodInfoItem = {
      type: dinnerMenu.dishCategoryName,
      foods: foods,
    };
    items.push(item);
  }
  return items;
}
