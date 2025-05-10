import { queryRecipeCategory, RecipeCategory } from 'network';

const TAG = '[ClassificationVM]';

@ObservedV2
export class ClassificationVM {
  @Trace currentIndex: number = 0
  @Trace recipeCategoryList: RecipeCategory[] = []
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  private static _instance: ClassificationVM;

  public static get instance() {
    if (!ClassificationVM._instance) {
      ClassificationVM._instance = new ClassificationVM();
    }
    return ClassificationVM._instance;
  }

  init() {
    queryRecipeCategory().then(res => {
      if (res.status === 200) {
        this.recipeCategoryList = res.data
      }
    })
  }

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }
}
