import { BreakpointModel, BreakpointType } from 'commonlib';
import { RecipeCategory } from 'link_category';
import { queryRecipeCategory } from 'network';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG = '[ClassificationVM]';

@ObservedV2
export class ClassificationVM {
  @Trace recipeCategoryList: RecipeCategory[] = []
  @Trace currentIndex: number = 0
  private static _instance: ClassificationVM;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 3,
    md: 4,
    lg: 5,
    xl: 5,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

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

  changeCurrentIndex(index: number) {
    this.currentIndex = index
  }

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}
