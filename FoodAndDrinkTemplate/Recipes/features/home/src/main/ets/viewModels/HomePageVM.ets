import { TabItem } from '../types/Index';
import { queryRecipeList, RecipeBriefInfo } from 'network';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  @Trace bannerUrl: ResourceStr[] = [$r('app.media.banner1'), $r('app.media.banner2')];
  @Trace dishesList: RecipeBriefInfo[] = []
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
      icon: $r('app.media.ic_home_dish'),
    },
    {
      label: '更多',
      icon: $r('app.media.ic_more'),
    },
  ];
  // 搜索框是否可见
  @Trace isSearchVisible: boolean = false
  private static _instance: HomePageVM;

  public async getDishesList() {
    const res = await queryRecipeList()
    if (res.status === 200) {
      this.dishesList = res.data
    }
  }


  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }
}
