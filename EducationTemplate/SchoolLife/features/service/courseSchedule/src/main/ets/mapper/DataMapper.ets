import { ScheduleInfo } from '@hw-agconnect/ui-schedule-flow';
import { CourseDetail } from 'commonlib';


export function mappedCourseDetailList(courseDetailList: CourseDetail[]): ScheduleInfo[] {
  const scheduleInfoList: ScheduleInfo[] = [];
  courseDetailList.forEach((courseDetail: CourseDetail) => {
    scheduleInfoList.push(new ScheduleInfo(
      courseDetail.daySchedule,
      courseDetail.weekDay,
      `${courseDetail.courseName}@${courseDetail.classroom}`));
  });
  return scheduleInfoList;
}