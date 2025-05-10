import { queryRecipeHistoryList } from 'network';
import { recipeListMapper } from '../mapper/Index';
import { RecipeItem } from '../types/Index';


@ObservedV2
export class BrowsingHistoryVM {
  private static _instance: BrowsingHistoryVM;
  @Trace history: RecipeItem[] = [];

  async queryRecipeHistory() {
    const res: ESObject = await queryRecipeHistoryList();
    this.history = recipeListMapper(res.data);
  }

  public static get instance() {
    if (!BrowsingHistoryVM._instance) {
      BrowsingHistoryVM._instance = new BrowsingHistoryVM();
    }
    return BrowsingHistoryVM._instance;
  }
}
