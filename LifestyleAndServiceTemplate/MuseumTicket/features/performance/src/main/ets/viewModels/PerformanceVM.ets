import { PerformanceListItem } from '../types/Index';
import { https, RecommendListItem } from 'network';
import { RouterModule, RouterMap, FormatUtil } from 'commonlib';


const TAG = '[PerformanceVM]';

@ObservedV2
export class PerformanceVM {
  @Trace performanceInfo: PerformanceListItem | undefined = undefined;
  // 精彩推荐
  @Trace recommendList: RecommendListItem[] = [];
  @Trace isLoading: boolean = false;
  private static _instance: PerformanceVM;

  public static get instance() {
    if (!PerformanceVM._instance) {
      PerformanceVM._instance = new PerformanceVM();
    }
    return PerformanceVM._instance;
  }


  public async getRecommendList() {
    https.getRecommendList().then(res => {
      if (res.code === 0) {
        res.data.forEach((item: RecommendListItem, index) => {
          const img = FormatUtil.getImgResource(item.img);
          this.recommendList.push({
            id: item.id,
            price: item.price,
            img: img,
            name: item.name,
            detail: item.detail,
          });
        });
      }
    });
  }

  public clearRecommendList() {
    this.recommendList = [];
  }


  public async getPerformanceInfo() {
    this.isLoading = true;
    const params: Record<string, string> | undefined = RouterModule.getNavParam({ url: RouterMap.PERFORMANCE_DETAIL });
    if (params) {
      const res = await https.getPerformanceInfo();
      if (res.code === 0) {
        this.performanceInfo = res.data.find((item) => item.performanceId === params.id) as PerformanceListItem;
        this.performanceInfo.img = FormatUtil.getImgResource(this.performanceInfo.img);
        this.isLoading = false;
      }
    }
  }

  public clear() {
    this.performanceInfo = undefined;
  }
}