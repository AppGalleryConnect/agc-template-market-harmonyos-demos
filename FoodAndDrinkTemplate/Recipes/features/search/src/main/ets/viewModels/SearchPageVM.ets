import { SortType, TabItem } from '../types/Index';
import { queryRecipeList, querySearchHotkeys, RecipeBriefInfo } from 'network';
import { RouterMap, RouterModule } from 'commonlib';

const TAG = '[SearchPageVM]';

@ObservedV2
export class SearchPageVM {
  @Trace historyInfo: string[] = [];
  @Trace hotInfo: string[] = [];
  @Trace tabList: TabItem[] =
    [{ label: '综合', sortType: SortType.General }, { label: '收藏最多', sortType: SortType.Grade },
      { label: '浏览最多', sortType: SortType.Cooked }];
  // 搜索结果
  @Trace resultList: RecipeBriefInfo[] = [];
  // 搜索框聚焦
  @Trace isFocus: boolean = true;
  // 是否展示搜索结果
  @Trace isShowResult: boolean = true;
  @Trace keyword: string = '';
  // 当前tab栏索引
  @Trace curTabIndex: number = 0;
  private static _instance: SearchPageVM;

  public static get instance() {
    if (!SearchPageVM._instance) {
      SearchPageVM._instance = new SearchPageVM();
    }
    return SearchPageVM._instance;
  }


  // 搜索菜谱
  public async searchDishes() {
    const res = await queryRecipeList({ name: this.keyword });
    // 插入历史记录,并去重
    this.historyInfo.unshift(this.keyword);
    this.historyInfo = Array.from(new Set(this.historyInfo));
    if (res.status === 200) {
      this.resultList = res.data;
      this.isShowResult = true;
    }
  }


  public async getHotkeys() {
    const res = await querySearchHotkeys();
    if (res.status === 200) {
      this.hotInfo = res.data;
    }
  }

  public getDefaultSearch() {
    const params: Record<string, string> | undefined = RouterModule.getNavParam({ url: RouterMap.SEARCH });
    if (params) {
      this.keyword = params.keyword;
      this.searchDishes();
    }
  }
}
