import { BreakpointModel, BreakpointType } from 'commonlib';
import { queryRecipeList, RecipeBriefInfo } from 'network';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class HealthyRecipesPageVM {
  listScroller: Scroller = new Scroller();
  @Trace currentIndex: number = 0;
  @Trace recipeList: RecipeBriefInfo[] = [];
  @Trace healthyRecipes: string[][] = [['西兰花', '黄瓜', '彩椒'],['四季豆', '茄子', '西红柿'],
    ['生菜', '豆腐', '清蒸鱼'],['盐水下', '醋溜白菜', '粉丝蒸扇贝']];
  @Trace title: string = '减脂';
  @Trace icon: string = 'ic_reduce_fat_icon1';
  @Trace fontColor: string = '';
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  public async getDishesList(keyword: string = '') {
    if(keyword === '精选推荐') {
      keyword = '';
    }
    const res = await queryRecipeList({ name: keyword });
    if (res.status === 200) {
      this.recipeList = res.data;
    }
  }

  @Computed
  get getLanes() {
    let lanes = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return lanes;
  }
}