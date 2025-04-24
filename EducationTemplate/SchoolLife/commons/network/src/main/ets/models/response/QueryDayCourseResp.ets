
export interface SimpleCourseInfo {
  courseName: string;
  classroom: string;
  teacher: string;
  weekDay: number;
  daySchedule: number[];
  weekSchedule: number[];
}

export interface QueryDayCourseResp {
  courseList: SimpleCourseInfo[];
}