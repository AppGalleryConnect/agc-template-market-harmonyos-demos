import { HashMap } from '@kit.ArkTS';
import { Pair } from '../type/CommonType';

export function pad(n: number): string {
  return n < 10 ? '0' + n : n.toString();
}

const semesterStartTime = new Date('2025/3/31');

export class ScheduleConfig {
  /**
   * 单日上课时间段分布列表，比如 1 - "8:05-8:50" 2 - "9:00-9:45"
   */
  courseTimeRangeList: HashMap<number, string> = new HashMap();

  /**
   * 单学期总周数
   */
  totalWeekNum: number;

  /**
   *  分割上下午时间点，例如“5”-表示 1~5节为上午，其余课程为下午
   */
  divideTime: number = 0;

  constructor(courseTimeRangeList?: HashMap<number, string>, totalWeekNum?: number, divideTime?: number) {
    this.courseTimeRangeList = courseTimeRangeList ?? new HashMap();
    this.totalWeekNum = totalWeekNum ?? 0;
    this.divideTime = divideTime ?? 0;
  }
}

class ScheduleConfigUtil {
  // 课程排布基础配置
  private _scheduleConfig: ScheduleConfig = new ScheduleConfig();

  public initSchedule(scheduleConfig: ScheduleConfig) {
    this._scheduleConfig = scheduleConfig;
  }

  // 查看课程是上午还是下午
  public getCoursePeriod(daySchedule: number[]): Resource {
    if (daySchedule[1] <= this._scheduleConfig.divideTime) {
      return $r('app.string.am');
    } else {
      return $r('app.string.pm');
    }
  }

  // 查看课程上课时间
  public getDayScheduleTimeString(daySchedule: number[]): string {
    if (daySchedule.length < 2) {
      return '';
    }
    const start = this._scheduleConfig.courseTimeRangeList.get(daySchedule[0]).split('-')[0];
    const end = this._scheduleConfig.courseTimeRangeList.get(daySchedule[1]).split('-')[1];
    return `${start}-${end}`;
  }

  // 获取上课下课时间点
  public getDayScheduleDate(daySchedule: number[], dateTime: Date): Pair<Date, Date> {
    const start = this._scheduleConfig.courseTimeRangeList.get(daySchedule[0]).split('-')[0];
    const end = this._scheduleConfig.courseTimeRangeList.get(daySchedule[1]).split('-')[1];
    const startTime = new Date(dateTime);
    startTime.setHours(Number(start.split(':')[0]));
    startTime.setMinutes(Number(start.split(':')[1]));
    startTime.setSeconds(0);
    const endTime = new Date(dateTime);
    endTime.setHours(Number(end.split(':')[0]));
    endTime.setMinutes(Number(end.split(':')[1]));
    endTime.setSeconds(0);
    return new Pair(startTime, endTime);
  }

  // 获取当前学期开始/结束时间
  public getSemesterTimeRange(): Pair<Date, Date> {
    const semesterEndTime = new Date(semesterStartTime);
    semesterEndTime.setTime(semesterStartTime.getTime() + this._scheduleConfig.totalWeekNum * 7 * 24 * 60 * 60 * 1000);
    return new Pair(semesterStartTime, semesterEndTime);
  }

  // 获取当前周数
  public getCurrentWeek(dateTime: Date): number {
    // 根据当前学期开学日期计算得出
    const semesterStartTime = this.getSemesterTimeRange().first;
    semesterStartTime.setDate(semesterStartTime.getDate() - semesterStartTime.getDay());
    const now = new Date(dateTime);
    now.setDate(now.getDate() - now.getDay());
    const diffMilliseconds = Math.abs(dateTime.getTime() - semesterStartTime.getTime()); // 取相差毫秒数的绝对值
    const currentWeek = Math.ceil(diffMilliseconds / (1000 * 3600 * 24 * 7)); // 向下取整
    return currentWeek;
  }

  // 获取当前周日期范围，返回字符串如02.17--02.23
  public getWeekRange(dateTime: Date): Pair<Date, Date> {
    const day = dateTime.getDay() === 0 ? 7 : dateTime.getDay();
    const start = new Date(dateTime);
    start.setDate(dateTime.getDate() - day + 1);
    const end = new Date(dateTime);
    end.setDate(dateTime.getDate() + 7 - day);
    return new Pair(start, end);
  }

  public getWeekRangeString(dateTime: Date) {
    const pair = this.getWeekRange(dateTime);
    const start = pair.first;
    const end = pair.second;
    const startMonth = pad(start.getMonth() + 1);
    const startDate = pad(start.getDate());
    const endMonth = pad(end.getMonth() + 1);
    const endDate = pad(end.getDate());
    return `${startMonth}.${startDate}--${endMonth}.${endDate}`;
  }

  // 获取分割时间段
  public getDivideTime(): number {
    return this._scheduleConfig.divideTime;
  }

  // 获取课程总节数
  public getDayScheduleMax(): number {
    return this._scheduleConfig.courseTimeRangeList.length;
  }

  // 标准化Date时分秒
  public normalizeDate(dateTime: Date): Date {
    const normalizedDate = new Date(dateTime);
    normalizedDate.setHours(0);
    normalizedDate.setMinutes(0);
    normalizedDate.setSeconds(0);
    return normalizedDate;
  }

  // 查看两个日期是否在同一天
  public isSameDate(dateTime1: Date, date2Time: Date): boolean {
    return dateTime1.toLocaleDateString() === date2Time.toLocaleDateString();
  }
}

const scheduleConfigUtil = new ScheduleConfigUtil();
export { scheduleConfigUtil as ScheduleConfigUtil };