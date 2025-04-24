export interface CourseScheduleConfigResp {
  /**
   * 单日上课时间段分布列表，比如 "8:05-8:50" "9:00-9:45"。列表长度为课时总节数
   */
  courseTimeRangeList: string[];

  /**
   * 单学期总周数
   */
  totalWeekNum: number;

  /**
   *  分割上下午时间点，例如“4”-表示 1~4节为上午，其余课程为下午
   */
  divideTime: number;
}

