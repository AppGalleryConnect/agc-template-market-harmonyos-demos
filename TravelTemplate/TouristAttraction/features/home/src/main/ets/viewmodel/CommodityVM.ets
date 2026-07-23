import { LazyDataSource, Logger } from 'common';
import { https } from 'network';
import { mapperCommodityList } from '../mapper/Index';
import { CommodityInfo } from '../model/CommodityInfo';
import { CommodityTabBarType } from '../model/CommodityTabInfo';

@ObservedV2
export class CommodityVM {
  public static _instance: CommodityVM;
  @Trace specialCommodityList: LazyDataSource<CommodityInfo> = new LazyDataSource();
  @Trace culturalCommodityList: LazyDataSource<CommodityInfo> = new LazyDataSource();

  public static get instance() {
    if (!CommodityVM._instance) {
      CommodityVM._instance = new CommodityVM();
    }
    return CommodityVM._instance;
  }

  getCommodityList(type: number = CommodityTabBarType.SPECIAL) {
    https.getCommodityList(type).then((res) => {
      const list = mapperCommodityList(res.data);
      if (type === CommodityTabBarType.SPECIAL) {
        this.specialCommodityList.pushArrayData(list);
      } else {
        this.culturalCommodityList.pushArrayData(list);
      }
      Logger.info('commodity count is' + list.length);
    });
  }
}