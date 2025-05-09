import {
  CourseInfo,
  CourseTypeMap,
  StoreConfig,
  PreloadUtil,
  RouterMap,
  RouterModule,
  StoreInfo,
  AppStorageMap,
  DialogMap,
} from 'commonlib';
import { https } from 'network';
import { MainServiceMap, StoreInfoTypeMap } from '../constants/Enums';
import { MainEntryVM } from './MainEntryVM';
import { MineVM } from './MineVM';
import { StoreMapVM } from './StoreMapVM';

@ObservedV2
export class HomeVM {
  // 线上课程列表
  @Trace onlineList: CourseInfo[] = [];
  // 线下课程列表
  @Trace offlineList: CourseInfo[] = [];
  // 首页轮播
  @Trace banners: ResourceStr[] = [];
  // 商铺信息
  @Trace storeInfo: StoreInfo | null = null;
  private readonly _mainVM: MainEntryVM = MainEntryVM.instance;
  private readonly _mapVM: StoreMapVM = StoreMapVM.instance;
  private readonly _mineVM: MineVM = MineVM.instance;
  private static _instance: HomeVM;

  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }

  public async initHomePage() {
    const preloadRes = PreloadUtil.getPreloadResult();
    if (preloadRes) {
      this.getPageData(preloadRes);
    }
    if (this.storeInfo && this.banners && this.onlineList && this.offlineList) {
      return;
    }
    const res = await https.getStoreConfig();
    if (res.ret.code === 0) {
      this.getPageData(res.result);
    }
  }

  public async getPageData(res: StoreConfig) {
    if (res.banners) {
      this.banners = res.banners;
    }
    if (res.courseList) {
      this.onlineList = res.courseList.filter((item) => item.type === CourseTypeMap.ONLINE);
      this.offlineList = res.courseList.filter((item) => item.type === CourseTypeMap.OFFLINE);
    }
    if (res.storeInfo) {
      this.storeInfo = res.storeInfo;
      AppStorage.setOrCreate(AppStorageMap.STORE_PHONE, res.storeInfo.phoneNumber);
      this._mineVM.initStoreInfo(res.storeInfo);
    }
  }

  // 首页功能点击跳转
  public jumpToMainService(type: MainServiceMap) {
    switch (type) {
      case MainServiceMap.COURSES_COLUMN:
        this.jumpToCourseCenter();
        break;
      case MainServiceMap.ONLINE_COURSES:
        this.jumpToCourseCenter(CourseTypeMap.ONLINE);
        break;
      case MainServiceMap.OFFLINE_STORE:
        RouterModule.push({
          url: RouterMap.HOME_LOCATION,
          param: this.storeInfo,
        });
        break;
      case MainServiceMap.ABOUT_US:
        RouterModule.push({
          url: RouterMap.HOME_STORE_INTRODUCTION,
          param: this.storeInfo,
        });
        break;
      default:
        break;
    }
  }

  public jumpToCourseCenter(type: CourseTypeMap = CourseTypeMap.ALL) {
    this._mainVM.changeTabToCourseCenter(type);
  }

  public handleClickStoreInfo(type: StoreInfoTypeMap) {
    switch (type) {
      case StoreInfoTypeMap.LOCATION:
        this._mapVM.handleClickGuide();
        break;
      case StoreInfoTypeMap.PHONE:
        RouterModule.push({
          url: DialogMap.CONTACT_CUSTOM_SERVICE,
          param: this.storeInfo?.phoneNumber,
        });
      default:
        break;
    }
  }

  public handleClickCourseCard(course: CourseInfo) {
    RouterModule.push({
      url: RouterMap.COURSE_DETAIL,
      param: course,
    });
  }
}