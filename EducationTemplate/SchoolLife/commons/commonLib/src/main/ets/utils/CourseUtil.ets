import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap, ScheduleConfigUtil, ScheduleFlag } from '../../../../Index';

@ObservedV2
export class CourseDetail {
  courseName: string = '';
  classroom: string = '';
  teacher: string = '';
  weekDay: number = 0;
  weekSchedule: number[] = [];
  daySchedule: number[] = [];
  scheduleFlag: string = ScheduleFlag.NORMAL;
}

@ObservedV2
export class AllCourseInfo {
  @Trace studentNo: string = '';
  semester: number = 0;
  courseInfoList: CourseDetail[] = [];
}

class CourseUtil {
  private _allCourseInfo: AllCourseInfo = AppStorageV2.connect(
    AllCourseInfo,
    AppStorageMap.ALL_COURSE_INFO,
    () => new AllCourseInfo()
  )!;

  public setCourseInfo(courseInfoList: AllCourseInfo) {
    this._allCourseInfo.studentNo = courseInfoList.studentNo;
    this._allCourseInfo.semester = courseInfoList.semester;
    this._allCourseInfo.courseInfoList = courseInfoList.courseInfoList;
  }

  // 获取当前周所有课程
  public getWeekCourseInfo(dateTime: Date): CourseDetail[] {
    const curWeek = ScheduleConfigUtil.getCurrentWeek(dateTime);
    const courseDetailList: CourseDetail[] = [];
    this._allCourseInfo.courseInfoList.forEach((courseDetail: CourseDetail) => {
      // 查看是否在当前周
      if (courseDetail.weekSchedule.some((week) => week === curWeek)) {
        courseDetailList.push(courseDetail);
      }
    });
    return courseDetailList;
  }

  // 查询课程详细信息
  public getCourseDetail(courseName: string): CourseDetail | undefined {
    if (this._allCourseInfo.studentNo === '') {
      return undefined;
    }
    return this._allCourseInfo.courseInfoList
      .find((courseDetail: CourseDetail) => courseDetail.courseName === courseName);
  }
}

const courseUtil = new CourseUtil();
export { courseUtil as CourseUtil };