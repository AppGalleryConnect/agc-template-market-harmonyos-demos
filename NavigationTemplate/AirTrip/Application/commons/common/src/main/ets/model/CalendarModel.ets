import { CalendarViewType } from '../constants/CommonEnums';

/**
 * 自定义日历控制器。用于控制年、月、周视图间切换场景下刷新日期数据。
 */
export class CalendarController {
  // 视图刷新接口
  swiperRefresh = (value: CalendarViewType) => {
  };
  // 视图刷新接口（仅用于在年视图上点击月份切换到月视图时刷新）
  swiperYearToMonthRefresh = (year: number, month: number) => {
  };
  // 日程点数据刷新接口
  schedulePointRefresh = () => {
  };
}

/**
 * 一天的信息
 */
@ObservedV2
export class DayInfo {
  @Trace year: number; // 年
  @Trace month: number; // 月
  @Trace date: number; // 日
  @Trace weekDay: string; // 星期几
  @Trace currentDayFlightLowPrice: number = -1 // 当前日期的航班最低价格

  constructor(year: number, month: number, date: number, weekDay: string) {
    this.year = year;
    this.month = month;
    this.date = date;
    this.weekDay = weekDay;
  }
}

/**
 * 自定义日历样式。仅用于月、周视图。
 */
export interface CalendarStyle {
  textScaling?: number; // 月视图和周视图中的公历、农历、星期、年月信息标题文字缩放比例。
  backgroundColor?: Color | number | string | Resource; // 今天选中日期的背景色
  monthDayColor?: Color | number | string | Resource; // 本月公历日期颜色
  noMonthDayColor?: Color | number | string | Resource; // 非本月公历日期颜色，仅对月视图有效。
  lunarColor?: Color | number | string | Resource; // 本月农历字体颜色
}

/**
 * 一天的信息。包含农历
 */
export interface Day {
  dayNum: number, // 日期
  lunarDay: string, // 农历中文日期
  dayInfo: DayInfo, // 一天的年月日信息
}

/**
 * 日期信息。用于选择日期回调
 */
export interface CalendarData {
  year: number, // 年
  month: number, // 月
  date: number, // 日
}

/**
 * 年、月、周视图切换场景的相关设置
 */
export interface CalendarSwitch {
  controller?: CalendarController; // 自定义日历控制器，用于视图切换后的数据刷新。
  currentSelectDay?: DayInfo; // 记录月、周视图中点击选中的日期信息。
  isYearMonthHidden?: boolean; // 是否隐藏自定义日历年、月、周视图中自带的年月信息标题。
}

/**
 * 日程点相关信息
 */
@Observed
export class ScheduleInfo {
  title: string; // 标题
  location: string; // 地点
  startTime: Date; // 开始时间
  endTime: Date; // 结束时间
  describe: string; // 说明
  dateString: string; // 开始时间startTime里的年月日，如'2024/11/5'
  reminderTime: number[]; // 提醒时间

  constructor(title: string, location: string, startTime: Date, endTime: Date, describe: string,
    dateString: string, reminderTime: number[]) {
    this.title = title;
    this.location = location;
    this.startTime = startTime;
    this.endTime = endTime;
    this.describe = describe;
    this.dateString = dateString;
    this.reminderTime = reminderTime;
  }
}

/**
 * 公共数据类
 */
export default class CommonData {
  // 日程点年月日数组，用于月视图和周视图日程点刷新
  public static SCHEDULE_ARRAY: string[] = [];
  // 日程点数组，用于应用持久化存储日程信息
  public static SCHEDULE_DATA: Array<ScheduleInfo> = [];
  // 月视图/周视图上当前选中的日期
  public static CURRENT_SELECT_DATE: string = '';
}