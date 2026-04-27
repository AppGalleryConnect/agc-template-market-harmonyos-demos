import { AccountUtil, BreakpointModel, BreakpointType, GlobalContextUtils, UserInfo } from 'commonlib';
import { LazyDataSource, TabItem } from 'featured_recipes';
import { deleteMyRecipe, queryRecipeList, RecipeBriefInfo } from 'network';
import { AppStorageV2 } from '@kit.ArkUI';
import { WindowModels } from '../models/WindowModels';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  @Trace bannerUrl: ResourceStr[] =
    [$r('app.media.banner_img1'), $r('app.media.food_img'), $r('app.media.banner_img3'), $r('app.media.banner_img2')];
  @Trace dishesList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Trace isRefreshing: boolean = false;
  @Trace isLoading: boolean = false;
  @Trace hasMore: boolean = true;
  @Trace breakpoint: string = 'sm';
  @Trace tabList: TabItem[] = [
    {
      label: '家常菜',
      icon: $r('app.media.ic_home_dish'),
    },
    {
      label: '下饭菜',
      icon: $r('app.media.ic_meal_dish'),
    },
    {
      label: '快手菜',
      icon: $r('app.media.ic_fast'),
    },
    {
      label: '减脂餐',
      icon: $r('app.media.ic_fat'),
    },
    {
      label: '更多',
      icon: $r('app.media.ic_more'),
    },
  ];
  // 搜索框是否可见
  @Trace isSearchVisible: boolean = false
  @Trace totalCount = 75; //实际以接口为准
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 2,
    lg: 4,
    xl: 4,
  });
  marginOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 0,
    md: 0,
    lg: 88,
    xl: 88,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace searchResults: string[] = ['精选推荐', '下饭菜', '快手菜', '减脂餐', '家常菜', '豆制品', '蔬菜'];
  @Trace tabBarScroller: Scroller = new Scroller();
  @Trace subTabIndex: number = 0;
  @Trace themeColor: ResourceColor = '#FD4238';
  @Trace scroller: Scroller = new Scroller();
  @Trace recipesTitle: string = '精选推荐';
  @Trace windowModel: WindowModels = AppStorageV2.connect(WindowModels, () => new WindowModels())!;
  @Trace showBgColor: boolean = false;
  @Trace bgOpacity: number = 1;
  private static _instance: HomePageVM;

  public async getDishesList(keyword: string = '') {
    if (keyword === '精选推荐') {
      keyword = '';
    }
    const res = await queryRecipeList({ name: keyword });
    if (res.status === 200) {
      this.dishesList.pushArrayData(res.data)
    }
  }

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  async deleteMyRecipe(id: number, index: number) {
    const result = await deleteMyRecipe([id]);
    if (result.status === 200) {
      this.dishesList.deleteData(index);
    }
  }

  public async loadMore() {
    if (this.isLoading || !this.hasMore) {
      return
    }

    this.isLoading = true;
    await new Promise<void>(resolve => setTimeout(resolve, 1000)) // 模拟请求

    if (this.dishesList.totalCount() < this.totalCount) {
      this.dishesList.appendArrayData(this.dishesList.getDataList().slice(0, 25));
    } else {
      this.hasMore = false;
      this.emptyToast();
    }
    this.isLoading = false;
  }

  public emptyToast() {
    GlobalContextUtils.showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }


  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get getMargin() {
    return this.marginOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}
