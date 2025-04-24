
export interface TotalCourseInfo {
  courseName: string;
  classroom: string;
  teacher: string;
  weekDay: number;
  weekSchedule: number[];
  daySchedule: number[];
  scheduleFlag: string;
}

export interface QueryAllCourseResp {
  studentNo: string;
  semester: number;
  courseList: TotalCourseInfo[];
}