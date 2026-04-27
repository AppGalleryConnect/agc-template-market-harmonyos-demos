@ObservedV2
export class CategoryController {
  private static _instance: CategoryController;

  public static get instance() {
    if (!CategoryController._instance) {
      CategoryController._instance = new CategoryController();
    }
    return CategoryController._instance;
  }
  @Trace openCategorySheet: boolean = false;
}