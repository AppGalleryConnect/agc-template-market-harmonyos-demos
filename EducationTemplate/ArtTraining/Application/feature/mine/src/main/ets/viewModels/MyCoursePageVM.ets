import { CourseInfo, FrameworkUtil, RouterModule, TabsIndexMap } from 'commonlib';
import { https } from 'network';
import { MY_COURSE_TAB_LIST } from '../constants/Constants';

@ObservedV2
export class MyCoursePageVM {
  // 首页数据模型
  @Trace courseList: CourseInfo[] = [];
  @Trace isLoading: boolean = false;
  @Trace currentIndex: number = 0;
  tabController: TabsController = new TabsController();
  private static _instance: MyCoursePageVM;

  public static get instance() {
    if (!MyCoursePageVM._instance) {
      MyCoursePageVM._instance = new MyCoursePageVM();
    }
    return MyCoursePageVM._instance;
  }

  public async initCourseList(index: number = 0) {
    this.isLoading = true;
    this.currentIndex = index;
    const courseStatus = MY_COURSE_TAB_LIST[index].status;
    const res = await https.getCourseListOrdered({
      courseStatus,
    });
    if (res.ret.code === 0) {
      this.courseList = res.result.courseList;
    }
    this.isLoading = false;
  }

  public jumpToCourseCenter() {
    FrameworkUtil.switchTab(TabsIndexMap.COURSES_LIST);
    RouterModule.clear();
  }
}