import { RouterMap, RouterModule } from 'commonlib';

@ObservedV2
export class FoodInfoPageVM {

  private static _instance: FoodInfoPageVM;


  public static get instance() {
    if (!FoodInfoPageVM._instance) {
      FoodInfoPageVM._instance = new FoodInfoPageVM();
    }
    return FoodInfoPageVM._instance;
  }

  public initData() {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.VIDEO_DETAIL_PAGE });
    if (param) {
    }
  }

}
