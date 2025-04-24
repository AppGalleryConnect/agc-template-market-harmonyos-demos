import { Guide, GUIDE_TABS_INFO, LocationType } from '../model/GuideInfo';
import { AccommodationInfo, AppStorageMap, AttractionInfo, CateringInfo, ToiletInfo } from 'types';
import { AttractionUtil, Constant, getPoiListByText, getPoiListByType } from 'common';
import { mapperToilet, mapSiteInfo } from '../mapper/Index';

@ObservedV2
export class GuideVM {
  // 默认展示景点列表
  @Trace guideInfo: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo> = GUIDE_TABS_INFO[0];
  public static _instance: GuideVM;

  public static get instance() {
    if (!GuideVM._instance) {
      GuideVM._instance = new GuideVM();
    }
    return GuideVM._instance;
  }

  public constructor() {
    this.initGuideInfo();
  }

  changeGuideInfo(type: number) {
    if (type === 1) {
      this.guideInfo.data = AppStorage.get(AppStorageMap.CATERING_LIST)!;
    } else if (type === 2) {
      this.guideInfo.data = AppStorage.get(AppStorageMap.ACCOMMODATION_LIST)!;
    } else if (type === 3) {
      this.guideInfo.data = AppStorage.get(AppStorageMap.TOILET_LIST)!;
    } else if (type === 0) {
      this.guideInfo.data = AttractionUtil.getAttraction().attractions;
    }
  }

  initGuideInfo() {
    this.guideInfo.data = AttractionUtil.getAttraction().attractions;

    getPoiListByText(Constant.TOILET).then((res) => {
      let toiletList = mapperToilet(res.sites ?? []);
      // 本地存储卫生间信息
      AppStorage.setOrCreate(AppStorageMap.TOILET_LIST, toiletList);
    });

    if (!AppStorage.get(AppStorageMap.ACCOMMODATION_LIST)) {
      getPoiListByType(1, 'ACCOMMODATION').then((res) => {
        let accommodationSites = mapSiteInfo(res.sites ?? [], LocationType.ACCOMMODATION);
        AppStorage.setOrCreate(AppStorageMap.ACCOMMODATION_LIST, accommodationSites)!;
      });
    }
    if (!AppStorage.get(AppStorageMap.CATERING_LIST)) {
      getPoiListByType(1, 'RESTAURANT').then((res) => {
        let cateringSites = mapSiteInfo(res.sites ?? [], LocationType.CATERING);
        AppStorage.setOrCreate(AppStorageMap.CATERING_LIST, cateringSites)!;
      });
    }
  }
}