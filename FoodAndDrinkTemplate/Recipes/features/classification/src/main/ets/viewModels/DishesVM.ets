import { AppStorageMap, Logger, RouterMap, RouterModule } from 'commonlib';
import { addCollection, queryRecipeDetail, RecipeDetail } from 'network';
import { BasketList } from '../types/Index';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG = '[DishesVM]';

@ObservedV2
export class DishesVM {
  @Trace recipeDetail?: RecipeDetail = undefined
  @Trace basketList: BasketList =
    PersistenceV2.connect(BasketList, AppStorageMap.SHOPPING_BASKET, () => new BasketList())!;
  @Trace collection: boolean = false
  scroller: Scroller = new Scroller();

  init(): void {
    let recipeRouter = RouterModule.getNavParam<RecipeDetail>({ url: RouterMap.DISHES })
    Logger.info('Dishes detail router params:', JSON.stringify(recipeRouter))
    queryRecipeDetail(recipeRouter?.id || 0).then(res => {
      if (res.status === 200) {
        this.recipeDetail = res.data
        this.collection = res.data.isCollected || false
      }
    })
  }

  addCollection(): void {
    addCollection(this.recipeDetail?.id || 0).then(res => {
      if (res.status === 200) {
        this.collection = !this.collection
      }
    })
  }
}
