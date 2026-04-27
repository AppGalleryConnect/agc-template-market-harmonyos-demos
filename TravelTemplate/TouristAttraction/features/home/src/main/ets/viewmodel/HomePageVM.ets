import { AppStorageV2 } from '@kit.ArkUI';
import { https, GetHomeInfoResp, mapperAttractionsInfo, httpsMock } from 'network';
import { AttractionUtil, LazyDataSource, LocationUtil, Logger } from 'common';
import { AttractionInfo, AttractionLiveInfo, RealTimeInfo, ToiletInfo } from 'module_base';
import { ContactInfo, NoteInfo } from 'types';
import { ParkInfo } from '../model/HomeRollupInfo';
import { RealTimeItem } from '../model/Index';
import { BulletinInfo } from '../model/BulletinInfo';
import { mapperBulletinList, mapperHotNote, mapperNoteList } from '../mapper/Index';
import { ParkingSlotInfo } from '../model/ParkingSlotInfo';

@ObservedV2
export class HomePageVM {
  @Trace isLoading: boolean = true;
  @Trace noteList: LazyDataSource<NoteInfo> = new LazyDataSource();
  @Trace parkingSlotList: LazyDataSource<ParkingSlotInfo> = new LazyDataSource();
  @Trace toiletList: LazyDataSource<ToiletInfo> = new LazyDataSource();
  @Trace bulletinList: LazyDataSource<BulletinInfo> = new LazyDataSource();
  @Trace hotAttractionList: LazyDataSource<AttractionInfo> = new LazyDataSource();
  @Trace attractionList: LazyDataSource<AttractionInfo> = new LazyDataSource();
  @Trace attractionListBanner: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Trace rollUpInfo: GetHomeInfoResp | null = null;
  @Trace realTimeInfos: RealTimeInfo[] = [];
  @Trace scenicImages: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Trace attractionLiveInfo: AttractionLiveInfo = new AttractionLiveInfo();
  public static _instance: HomePageVM;
  private contactInfo: ContactInfo = AppStorageV2.connect(ContactInfo, 'contactInfo', () => new ContactInfo())!;

  getParkingSpace(): number {
    let count = 0;
    this.rollUpInfo?.parks.forEach((item: ParkInfo) => {
      count += item.spaces;
    });
    return count;
  }

  getNoteList() {
    https.getNoteList().then((res) => {
      this.noteList.pushArrayData(mapperNoteList(res.data));
    });
  }

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public constructor() {
    this.getRollupInfo();
    this.getAttractionList();
  }

  getAttractionList() {
    https.getAttractionList().then((res) => {
      // 将景点信息在本地缓存
      let attractions = mapperAttractionsInfo(res.data)
      AttractionUtil.setAttraction(attractions);
      this.attractionListBanner.pushArrayData(attractions.banners);
      this.attractionList.pushArrayData(attractions.attractions);
      this.hotAttractionList.pushArrayData(attractions.attractions.filter((item) => item.isHot === 1));
    });
  }

  getRollupInfo() {
    https.getHomeRollupInfo().then((res) => {
      this.rollUpInfo = res.data;
      this.scenicImages.pushArrayData(this.rollUpInfo.detailImages);
      this.realTimeInfos =
        [{ icon: $r('app.media.visitor'), item: RealTimeItem.CURRENT_VISITOR, count: this.rollUpInfo.currentVisitors },
          { icon: $r('app.media.parking'), item: RealTimeItem.PARKING_SPACE, count: this.getParkingSpace() }];
      this.contactInfo.consult = this.rollUpInfo.consultPhone;
      this.contactInfo.rescue = this.rollUpInfo.rescuePhone;
      this.contactInfo.complain = this.rollUpInfo.complaintPhone;
      LocationUtil.setLocationInfo(this.rollUpInfo.longitude, this.rollUpInfo.latitude);
      this.getAttractionLiveInfo()
      this.noteList.pushArrayData(mapperHotNote(this.rollUpInfo));
    });
  }

  getAttractionLiveInfo() {
    this.attractionLiveInfo.longitude = LocationUtil.getLocationInfo().longitude;
    this.attractionLiveInfo.latitude = LocationUtil.getLocationInfo().latitude;
    this.attractionLiveInfo.currentDate = this.rollUpInfo?.currentDate ?? new Date();
    this.attractionLiveInfo.temperature = this.rollUpInfo?.temperature ?? 0;
    this.attractionLiveInfo.currentDayVisitors = this.rollUpInfo?.currentDayVisitors ?? 0;
    this.attractionLiveInfo.maxVisitors = this.rollUpInfo?.maxVisitors ?? 0;
    this.attractionLiveInfo.maxInstantVisitors = this.rollUpInfo?.maxInstantVisitors ?? 0;
    this.attractionLiveInfo.weatherId = this.rollUpInfo?.weatherId ?? '';
    this.attractionLiveInfo.atmosphereId = this.rollUpInfo?.atmosphereId ?? '';
    this.attractionLiveInfo.atmosphereId = this.rollUpInfo?.atmosphereId ?? '';
    this.attractionLiveInfo.name = this.rollUpInfo?.name ?? '';
    this.attractionLiveInfo.realTimeInfos = this.realTimeInfos;
    this.attractionLiveInfo.openTime = this.rollUpInfo?.openTime ?? '';
    this.attractionLiveInfo.ticketTime = this.rollUpInfo?.ticketTime ?? ''
  }

  getBulletinList() {
    https.getBulletinList().then((res) => {
      this.bulletinList.pushArrayData(mapperBulletinList(res.data));
      this.isLoading = false;
      Logger.info('bulletin list is ' + this.bulletinList.totalCount());
    });
  }
}