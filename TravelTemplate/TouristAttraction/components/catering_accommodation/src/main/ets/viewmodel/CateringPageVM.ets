import { site } from '@kit.MapKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { LazyDataSource, LocationInfo } from 'module_base';
import { AccommodationInfo, CateringInfo, CateringTabBarType } from '../model/Index';
import { mapAccommodationInfo, mapCateringInfo } from '../mapper/Index';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class CateringPageVM {
  public static _instance: CateringPageVM;
  @Trace cateringList: LazyDataSource<CateringInfo> = new LazyDataSource();
  @Trace accommodationList: LazyDataSource<AccommodationInfo> = new LazyDataSource();
  private locationInfo: LocationInfo =
    PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;

  public static get instance() {
    if (!CateringPageVM._instance) {
      CateringPageVM._instance = new CateringPageVM();
    }
    return CateringPageVM._instance;
  }

  getCateringInfo(index: number) {
    index === CateringTabBarType.CATERING ? this.getCateringList() : this.getAccommodationList();
  }

  getAccommodationList() {
    this.getPoiListByType(1, 'ACCOMMODATION', 5000).then((res) => {
      let accommodationListResp = mapAccommodationInfo(res.sites ?? []);
      this.accommodationList.pushArrayData(accommodationListResp);
      // 本地存储
      AppStorage.setOrCreate('accommodationList', accommodationListResp);
    });
  }

  getCateringList() {
    this.getPoiListByType(1, 'EATING_DRINKING', 5000).then((res) => {
      let cateringListResp = mapCateringInfo(res.sites ?? []);
      this.cateringList.pushArrayData(cateringListResp);
      // 本地存储
      AppStorage.setOrCreate('cateringList', cateringListResp);
    });
  }

  getPoiListByType(pageIndex: number, poiType: string, range?: number) {
    let params: site.NearbySearchParams = {
      // 指定关键字
      query: '',
      // 经纬度坐标
      location: {
        latitude: this.locationInfo.latitude,
        longitude: this.locationInfo.longitude,
      },
      // 指定地理位置的范围半径
      radius: 1000,
      // 指定需要展示的poi类别
      poiTypes: [poiType],
      language: 'zh_CN',
      pageSize: 20,
      pageIndex: pageIndex,
    };
    // 返回周边搜索结果
    let result: Promise<site.NearbySearchResult> = new Promise((resolve, reject) => {
      reject(new Error('nearbySearch error'))
    })

    try {
      result = site.nearbySearch(params);
    } catch (e) {
      UtilLog.error(0x0000, 'AttractionGuideVM', `nearbySearch = ${JSON.stringify(e)}`);
    }

    return result
  }
}