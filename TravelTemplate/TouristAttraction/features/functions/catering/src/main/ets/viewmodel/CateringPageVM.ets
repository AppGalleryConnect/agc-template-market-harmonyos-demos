import { getPoiListByType, LazyDataSource, Logger } from 'common';
import { AccommodationInfo, AppStorageMap, CateringInfo } from 'types';
import { mapAccommodationInfo, mapCateringInfo } from '../mapper/Index';

@ObservedV2
export class CateringPageVM {
  @Trace cateringList: LazyDataSource<CateringInfo> = new LazyDataSource();
  @Trace accommodationList: LazyDataSource<AccommodationInfo> = new LazyDataSource();
  public static _instance: CateringPageVM;

  public static get instance() {
    if (!CateringPageVM._instance) {
      CateringPageVM._instance = new CateringPageVM();
    }
    return CateringPageVM._instance;
  }

  getCateringInfo() {
    this.getAccommodationList();
    this.getCateringList();
  }

  getAccommodationList() {
    getPoiListByType(1, 'ACCOMMODATION').then((res) => {
      let accommodationListResp = mapAccommodationInfo(res.sites ?? []);
      this.accommodationList.pushArrayData(accommodationListResp);
      // 本地存储
      AppStorage.setOrCreate(AppStorageMap.ACCOMMODATION_LIST, accommodationListResp);
      Logger.info('hotel total count is ' + this.cateringList.totalCount());
    });
  }

  getCateringList() {
    getPoiListByType(1, 'EATING_DRINKING').then((res) => {
      let cateringListResp = mapCateringInfo(res.sites ?? []);
      this.cateringList.pushArrayData(cateringListResp);
      // 本地存储
      AppStorage.setOrCreate(AppStorageMap.CATERING_LIST, cateringListResp);
      Logger.info('catering total count is ' + this.cateringList.totalCount());
    });
  }
}