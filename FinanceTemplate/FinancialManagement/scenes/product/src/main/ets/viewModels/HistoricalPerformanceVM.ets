import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { IHistoricalPerformance, IProductInfo, } from 'network/src/main/ets/types/responseTypes/GetProductResp';

const TAG = '[HistoricalPerformanceVM]';

@ObservedV2
export class HistoricalPerformanceVM {
  private static _instance: HistoricalPerformanceVM;
  @Trace public productInfo: IProductInfo | undefined
  @Trace public historicalPerformanceList: IHistoricalPerformance[] = []

  public static get instance() {
    if (!HistoricalPerformanceVM._instance) {
      HistoricalPerformanceVM._instance = new HistoricalPerformanceVM();
    }
    return HistoricalPerformanceVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<IProductInfo>({
      url: RouterMap.HISTORICAL_PERFORMANCE,
    });
    if (param) {
      this.productInfo = param
      this.getProductHistoricalPerformanceList(param.id)
    }

  }

  public async getProductHistoricalPerformanceList(id: number) {
    const res = await https.getProductHistoricalPerformanceList(id);
    if (res.code === 0) {
      this.historicalPerformanceList = res.data;
    }
  }
}
