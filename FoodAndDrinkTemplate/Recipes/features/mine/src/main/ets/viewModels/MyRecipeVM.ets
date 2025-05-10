import { queryMyRecipeList, RecipeBriefInfo } from 'network';

@ObservedV2
export class MyRecipeVM {
  private static _instance: MyRecipeVM;
  @Trace recipeList: RecipeBriefInfo[] = []

  public async getMyRecipeList() {
    const res = await queryMyRecipeList()
    if (res.status === 200) {
      this.recipeList = res.data
    }
  }

  public static get instance() {
    if (!MyRecipeVM._instance) {
      MyRecipeVM._instance = new MyRecipeVM();
    }
    return MyRecipeVM._instance;
  }
}