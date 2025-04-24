import { CourseUtil, ScheduleConfigUtil } from 'commonlib';
import { CourseApi } from 'network';
import { ResponseStatusCode } from 'network/src/main/ets/constants/NetworkEnums';
import { SimpleCourseInfo } from 'network/src/main/ets/models/response/QueryDayCourseResp';
import { mapAllCourseInfoResp, mapCourseScheduleConfigResp } from '../mapper/ResponseMapper';

@ObservedV2
export class HomePageVM {
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  @Trace todayCourseList?: SimpleCourseInfo[];
  @Trace tomorrowCourseList?: SimpleCourseInfo[];
  @Trace isLoading: boolean = true;
  @Trace courseInitFlag: boolean = false;

  // 初始化首页课程数据
  public async initCourseInfo() {
    // 查询课表基础配置
    const resp = await CourseApi.getScheduleConfig();
    ScheduleConfigUtil.initSchedule(mapCourseScheduleConfigResp(resp.data));

    // 查询今日，明日课表
    const semester = 4; // TODO: 后续根据学生入学年份和当天日期算出
    await Promise.all([
      this.queryDayCourse(semester),
      // 查询学期全部课表并缓存
      this.queryAllCourse(semester),
    ]);
  }

  public async queryAllCourse(semester: number) {
    const resp = await CourseApi.queryAllCourse(semester);
    CourseUtil.setCourseInfo(mapAllCourseInfoResp(resp.data));
  }

  public async queryDayCourse(semester: number) {
    this.isLoading = true;
    this.courseInitFlag = false;
    const date = new Date();
    const todayDateTime = date.toLocaleDateString();
    date.setDate(date.getDate() + 1);
    const tomorrowDateTime = date.toLocaleDateString();

    const responses = await Promise.all([
      CourseApi.queryDayCourse({ semester, dateTime: todayDateTime }),
      CourseApi.queryDayCourse({ semester, dateTime: tomorrowDateTime }),
    ]);
    const todayCourseResp = responses[0];
    if (todayCourseResp !== undefined && todayCourseResp.code === ResponseStatusCode.SUCCESS) {
      this.todayCourseList = todayCourseResp.data.courseList;
    }
    const tomorrowCourseResp = responses[1];
    if (tomorrowCourseResp !== undefined && tomorrowCourseResp.code === ResponseStatusCode.SUCCESS) {
      this.tomorrowCourseList = tomorrowCourseResp.data.courseList;
    }
    this.courseInitFlag = true;
    this.isLoading = false;
  }

  @Computed
  public get courseRequestSuccess() {
    return !this.courseInitFlag || this.todayCourseList && this.tomorrowCourseList;
  }
}
