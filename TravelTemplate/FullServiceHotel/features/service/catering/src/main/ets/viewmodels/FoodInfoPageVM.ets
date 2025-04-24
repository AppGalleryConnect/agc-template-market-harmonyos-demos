import { RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';
import { mapFoodInfoResponse } from '../mapper/FoodInfoMapper';
import { MappedFoodInfo } from '../models/MappedFoodInfo';
import { MealOrderVM } from './MealOrderVM';

@ObservedV2
export class FoodInfoPageVM {
  @Trace foodInfo: MappedFoodInfo | undefined = undefined;

  private static _instance: FoodInfoPageVM;

  private readonly mealOrderVm: MealOrderVM = MealOrderVM.instance;

  public static get instance() {
    if (!FoodInfoPageVM._instance) {
      FoodInfoPageVM._instance = new FoodInfoPageVM();
    }
    return FoodInfoPageVM._instance;
  }

  public initData() {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.RESTAURANT_FOOD_INFO });
    if (param) {
      this.getFoodInfo(param);
    }
  }

  public async getFoodInfo(mealPackageId: number) {
    this.foodInfo = undefined;
    const res = await https.getMealDetail(mealPackageId ?? -1);
    if (res.code === 0) {
      this.foodInfo = mapFoodInfoResponse(res.data);
      this.mealOrderVm.getMealInfo(res.data);
      this.mealOrderVm.foodInfo = mapFoodInfoResponse(res.data);
    }
  }
}
