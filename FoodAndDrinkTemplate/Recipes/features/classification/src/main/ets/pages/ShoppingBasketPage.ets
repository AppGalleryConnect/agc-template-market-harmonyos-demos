import { AppStorageMap, buildTitleBar, RouterMap, RouterModule } from 'commonlib';
import { LengthMetrics, PersistenceV2 } from '@kit.ArkUI';
import { BasketItem, ShoppingBasket } from 'shopping_basket';
import { BasketList } from '../types/Index';

@Builder
export function ShoppingBasketPageBuilder() {
  ShoppingBasketPage();
}

@ComponentV2
struct ShoppingBasketPage {
  @Local basketList: BasketList =
    PersistenceV2.connect(BasketList, AppStorageMap.SHOPPING_BASKET, () => new BasketList())!;

  build() {
    NavDestination() {
      ShoppingBasket({
        basketList: this.basketList.list,
        goRecipeDetail: (id: number) => {
          RouterModule.push(RouterMap.DISHES, { 'id': id } as Record<string, number>)
        },
        removeRecipe: (param: BasketItem) => {
          this.basketList.list = this.basketList.list.filter(i => i.id !== param.id)
        },
      })
    }
    .title(buildTitleBar('菜篮子'), { paddingStart: LengthMetrics.vp(16) })
    .padding({top: 40})
  }
}

