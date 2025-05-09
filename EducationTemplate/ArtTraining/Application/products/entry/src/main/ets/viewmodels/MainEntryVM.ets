import {
  AccountUtil,
  CloudStorageUtil,
  CourseTypeMap,
  FrameworkUtil,
  PreloadUtil,
  RouterModule,
  TabsIndexMap,
  UserInfoModel,
} from 'commonlib';
import { TAB_LIST } from '../constants/Constants';
import { https } from 'network';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.getStack();
  // tab页坐标
  @Trace curIndex: number = FrameworkUtil.currentIndex;
  // 用户信息
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  // 课程类型
  @Trace courseType: CourseTypeMap = CourseTypeMap.ALL;
  tabController: TabsController = FrameworkUtil.tabController;
  private static _instance: MainEntryVM;

  @Computed
  public get tabTitle() {
    return TAB_LIST[this.curIndex].label;
  }

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  // 初始化
  public async initData() {
    await PreloadUtil.preload();
    CloudStorageUtil.initBucket();
    https.getUserInfo().then((res)=> {
      if (res.ret.code === 0) {
        AccountUtil.setUserInfo(res.result);
      }
    });
  }

  // 切换tab页
  public changeTabIndex(index: TabsIndexMap) {
    FrameworkUtil.switchTab(index);
  }

  // 切换到课程中心
  public changeTabToCourseCenter(type: CourseTypeMap) {
    this.courseType = type;
    this.tabController.changeIndex(TabsIndexMap.COURSES_LIST);
  }
}
