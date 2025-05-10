import { queryCollectionList } from 'network';
import { recipeListMapper } from '../mapper/Index';
import { RecipeItem } from '../types/Index';

@ObservedV2
export class MyCollectionVM {
  private static _instance: MyCollectionVM;
  @Trace collections: RecipeItem [] = [];

  async queryCollection() {
    const res: ESObject = await queryCollectionList();
    this.collections = recipeListMapper(res.data);
  }

  public static get instance() {
    if (!MyCollectionVM._instance) {
      MyCollectionVM._instance = new MyCollectionVM();
    }
    return MyCollectionVM._instance;
  }
}