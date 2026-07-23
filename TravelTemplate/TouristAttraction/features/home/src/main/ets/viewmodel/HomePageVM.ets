import { AppStorageV2 } from '@kit.ArkUI';
import {
  AttractionUtil,
  BreakpointModel,
  BreakpointNameEnum,
  LazyDataSource,
  LocationUtil,
  Logger
} from 'common';
import { SourceImageModel } from 'image_preview';
import { AttractionInfo, AttractionLiveInfo, RealTimeInfo, ToiletInfo } from 'module_base';
import { GetHomeInfoResp, https, mapperAttractionsInfo } from 'network';
import { ContactInfo, NoteInfo } from 'types';
import { mapperBulletinList, mapperHotNote, mapperNoteList } from '../mapper/Index';
import { BulletinInfo } from '../model/BulletinInfo';
import { ParkInfo } from '../model/HomeRollupInfo';
import { RealTimeItem } from '../model/Index';
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
  @Trace resources: SourceImageModel[] = [];
  @Trace attractionLiveInfo: AttractionLiveInfo = new AttractionLiveInfo();
  // Scroll的偏移量
  @Trace scrollOffset: number = 0;
  // 创建Scroll对象
  scroller: Scroller = new Scroller();
  @Trace windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Trace windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private contactInfo: ContactInfo = AppStorageV2.connect(ContactInfo, 'contactInfo', () => new ContactInfo())!;

  public constructor() {
    this.getRollupInfo();
    this.getAttractionList();
  }

  public static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

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

  getAttractionList() {
    https.getAttractionList().then((res) => {
      // 将景点信息在本地缓存
      let attractions = mapperAttractionsInfo(res.data);
      AttractionUtil.setAttraction(attractions);
      this.attractionListBanner.pushArrayData(attractions.banners);
      this.attractionList.pushArrayData(attractions.attractions);
      this.hotAttractionList.pushArrayData(attractions.attractions.filter((item: AttractionInfo) => item.isHot === 1));
    });
  }

  getRollupInfo() {
    https.getHomeRollupInfo().then((res) => {
      this.rollUpInfo = res.data;
      this.scenicImages.pushArrayData(this.rollUpInfo.detailImages);
      this.resources = this.scenicImages.dataArray.map((imageUrl) => {
        return new SourceImageModel({ imageUrl });
      });
      this.realTimeInfos =
        [{ icon: $r('app.media.visitor'), item: RealTimeItem.CURRENT_VISITOR, count: this.rollUpInfo.currentVisitors },
          { icon: $r('app.media.parking'), item: RealTimeItem.PARKING_SPACE, count: this.getParkingSpace() }];
      this.contactInfo.consult = this.rollUpInfo.consultPhone;
      this.contactInfo.rescue = this.rollUpInfo.rescuePhone;
      this.contactInfo.complain = this.rollUpInfo.complaintPhone;
      LocationUtil.setLocationInfo(this.rollUpInfo.longitude, this.rollUpInfo.latitude);
      this.getAttractionLiveInfo();
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
    this.attractionLiveInfo.ticketTime = this.rollUpInfo?.ticketTime ?? '';
  }

  getBulletinList() {
    https.getBulletinList().then((res) => {
      this.bulletinList.pushArrayData(mapperBulletinList(res.data));
      this.isLoading = false;
      Logger.info('bulletin list is ' + this.bulletinList.totalCount());
    });
  }

  getTitleBarBgColor(): ResourceStr {
    if (this.breakPointModel.isLargeScreen) {
      return $r('sys.color.background_secondary');
    }
    const threshold = 96;
    const ratio = Math.min(Math.max(this.scrollOffset, 0) / threshold, 1);
    return `rgba(241, 243, 245, ${ratio * 0.8})`;
  }

  getTitleBarBackDropBar(): number {
    if (this.breakPointModel.isLargeScreen) {
      return 0;
    }
    const threshold = 96;
    const ratio = Math.min(Math.max(this.scrollOffset, 0) / threshold, 1);
    return ratio * 12;
  }

  getHotNoteTypeName(tag: number): string {
    if (tag === 1) {
      return '最新';
    } else if (tag === 2) {
      return '最热';
    } else {
      return '';
    }
  }

  getHotNoteTypeBgColor(tag: number): ResourceStr {
    if (tag === 1) {
      return $r('sys.color.mask_tertiary');
    } else if (tag === 2) {
      return $r('sys.color.alert');
    } else {
      return '';
    }
  }
}