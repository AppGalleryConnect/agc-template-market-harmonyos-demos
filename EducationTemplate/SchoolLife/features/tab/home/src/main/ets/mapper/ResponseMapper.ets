import { AllCourseInfo, CourseDetail, ScheduleConfig } from 'commonlib';
import { CourseScheduleConfigResp } from 'network/src/main/ets/models/response/CourseScheduleConfigResp';
import { HashMap } from '@kit.ArkTS';
import { QueryAllCourseResp } from 'network/src/main/ets/models/response/QueryAllCourseResp';


export function mapCourseScheduleConfigResp(courseScheduleConfigResp: CourseScheduleConfigResp): ScheduleConfig {
  let mappedScheduleConfig: ScheduleConfig = new ScheduleConfig(
    new HashMap<number, string>(),
    courseScheduleConfigResp.totalWeekNum,
    courseScheduleConfigResp.divideTime
  );
  courseScheduleConfigResp.courseTimeRangeList.forEach((timeRange: string, index: number) => {
    mappedScheduleConfig.courseTimeRangeList.set(index + 1, timeRange);
  });
  return mappedScheduleConfig;
}

export function mapAllCourseInfoResp(queryAllCourseResp: QueryAllCourseResp): AllCourseInfo {
  let mappedAllCourseInfo: AllCourseInfo = new AllCourseInfo();
  mappedAllCourseInfo.studentNo = queryAllCourseResp.studentNo;
  mappedAllCourseInfo.semester = queryAllCourseResp.semester;
  queryAllCourseResp.courseList.forEach((totalCourseInfo) => {
    const courseDetail = new CourseDetail();
    courseDetail.courseName = totalCourseInfo.courseName;
    courseDetail.classroom = totalCourseInfo.classroom;
    courseDetail.teacher = totalCourseInfo.teacher;
    courseDetail.weekDay = totalCourseInfo.weekDay;
    courseDetail.weekSchedule = totalCourseInfo.weekSchedule;
    courseDetail.daySchedule = totalCourseInfo.daySchedule;
    courseDetail.scheduleFlag = totalCourseInfo.scheduleFlag;
    mappedAllCourseInfo.courseInfoList.push(courseDetail);
  });
  return mappedAllCourseInfo;
}