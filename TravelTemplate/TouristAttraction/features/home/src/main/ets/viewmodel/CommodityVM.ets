import { LazyDataSource, Logger } from 'common';
import { https } from 'network';
import { mapperCommodityList } from '../mapper/Index';
import { CommodityInfo } from '../model/CommodityInfo';

@ObservedV2
export class CommodityVM {
  public static _instance: CommodityVM;
  @Trace type: number = 0;
  @Trace commodityList: LazyDataSource<CommodityInfo> = new LazyDataSource();

  public static get instance() {
    if (!CommodityVM._instance) {
      CommodityVM._instance = new CommodityVM();
    }
    return CommodityVM._instance;
  }

  getCommodityList() {
    https.getCommodityList(this.type).then((res) => {
      this.commodityList.pushArrayData(mapperCommodityList(res.data));
      Logger.info('commodity count is' + this.commodityList.totalCount());
    });
  }
}