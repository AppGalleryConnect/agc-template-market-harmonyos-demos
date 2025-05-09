import { i18n } from '@kit.LocalizationKit'; // 提供系统相关的或者增强的国际化能力。本例使用日历相关能力
import Constants from '../constants/Constants';
import { CalendarData, Day, DayInfo } from '../model/CalendarModel';

/**
 * 日期计算工具类
 */
export class TimeUtils {
  /**
   * 确定给的日期是星期几
   * @param year 年
   * @param month 月
   * @param day 日
   * @returns 周几
   */
  static getWeekDay(year: number, month: number, day: number): number {
    const DATE = new Date(year, month - 1, day);
    return DATE.getDay();
  }

  /**
   * 给定年份和月份的最后一天是几号
   * @param year 年
   * @param month 月
   * @returns
   */
  static getLastDayOfMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate();
  }

  /**
   * 用于获取前一个月的最后几天
   * @param year 年
   * @param month 月
   * @param firstDayOfWeek 当前月份的第一天是周几
   * @returns
   */
  static getPreviousMonthLastDays(year: number, month: number, firstDayOfWeek: number): number[] {
    const DAYS: number[] = [];
    const LAST_DAY_OF_PREVIOUS_MONTH = TimeUtils.getLastDayOfMonth(year, month - 1);
    for (let i = LAST_DAY_OF_PREVIOUS_MONTH - firstDayOfWeek + 1; i <= LAST_DAY_OF_PREVIOUS_MONTH; i++) {
      DAYS.push(i);
    }
    return DAYS;
  }

  /**
   * 用于生成当前月份的所有天数的数组
   * @param year 年
   * @param month 月
   * @returns 返回所有天数
   */
  static getCurrentMonthDays(year: number, month: number): number[] {
    const DAYS: number[] = [];
    const LAST_DAY_OF_MONTH = TimeUtils.getLastDayOfMonth(year, month);
    for (let i = 1; i <= LAST_DAY_OF_MONTH; i++) {
      DAYS.push(i);
    }
    return DAYS;
  }

  /**
   * 返回农历月份的中文表示
   * @param month 农历月
   * @returns
   */
  static lunarMonthToChinese(month: number): string {
    // 检查是否是闰月
    const IS_LEAP_MONTH = month < 0;
    const LUNAR_MONTH = IS_LEAP_MONTH ? -month : month;
    // 转换月份
    const CHINSES_MONTH_STR = `${Constants.CHINESE_MONTH[LUNAR_MONTH - 1]}月`;
    // 如果是闰月，加上“闰”字
    return IS_LEAP_MONTH ? `闰${CHINSES_MONTH_STR}` : CHINSES_MONTH_STR;
  }

  /**
   * 返回农历日期的中文表示
   * @param day 农历日
   * @returns
   */
  static lunarDayToChinese(day: number): string {
    // 转换日期
    return Constants.CHINESE_DAY[day - 1];
  }

  /**
   * 确定给的日期是星期几
   * @param year 年
   * @param month 月
   * @param day 日
   * @returns 周几
   */
  static getWeekDayStr(year: number, month: number, day: number): string {
    const today: Date = new Date();
    const newToday: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const DATE = new Date(year, month - 1, day);
    // 获取星期几 (0-6, 0 是周日，1 是周一，依此类推)
    const dayOfWeek = DATE.getDay();
    const diffDays = Math.floor((DATE.getTime() - newToday.getTime()) / (1000 * 60 * 60 * 24)); // 计算两个日期的天数差
    if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '明天';
    }
    // 如果日期不在今天、明天、后天范围内，返回周几
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekDays[dayOfWeek];
  }

  /**
   * 获取某年某月的所有日期
   * @param year
   * @param month
   * @returns
   */
  static byMonthDayForYear(year: number, month: number): Day[][] {
    const FIRST_DAY_OF_WEEK = TimeUtils.getWeekDay(year, month, 1);
    const PREVIOUS_MONTH_DAYS = TimeUtils.getPreviousMonthLastDays(year, month, FIRST_DAY_OF_WEEK);
    const CURRENT_MONTH_DAYS = TimeUtils.getCurrentMonthDays(year, month);
    const CALENDAR: Day[][] = [];
    let week: Day[] = [];
    let i18nCalendar: i18n.Calendar = i18n.getCalendar('zh-Hans', 'chinese');
    // 用上个月的天数填充第一周
    for (let i = 0; i < FIRST_DAY_OF_WEEK; i++) {
      i18nCalendar.setTime(new Date(year, month - 2, PREVIOUS_MONTH_DAYS[i]));
      week.push({
        dayNum: 0,
        lunarDay: '',
        dayInfo: new DayInfo((month - 1 < 1) ? year - 1 : year, (month - 1 < 1) ? 12 : month - 1,
          PREVIOUS_MONTH_DAYS[i], ''),
      });
    }

    // 用当月的天数填充剩余的周数
    for (const day of CURRENT_MONTH_DAYS) {
      i18nCalendar.setTime(new Date(year, month - 1, day));
      week.push({
        dayNum: day,
        lunarDay: i18nCalendar.get('date') === 1 ? TimeUtils.lunarMonthToChinese(i18nCalendar.get('month') + 1) :
        TimeUtils.lunarDayToChinese(i18nCalendar.get('date')),
        dayInfo: new DayInfo(year, month, day, TimeUtils.getWeekDayStr(year, month, day)),
      });
      if (week.length === Constants.DAYS_IN_WEEK) {
        CALENDAR.push(week);
        week = [];
      }
    }

    // 用下个月的日子填满最后一周
    if (week.length > 0) {
      let x = (Constants.DAYS_IN_WEEK - week.length);
      for (let index = 1; index <= x; index++) {
        i18nCalendar.setTime(new Date(year, month, index));
        week.push({
          dayNum: 0,
          lunarDay: '',
          dayInfo: new DayInfo((month + 1 > 12) ? year + 1 : year, (month + 1 > 12) ? 1 : month + 1, index, ''),
        });
      }
      CALENDAR.push(week);
    }
    return CALENDAR;
  }

  /**
   * 获取某周的所有日期
   * @param weekNum 距离本周的周数。本周用0表示，负数表示过去周，正数表示未来周，以此类推。
   * @returns 返回某周的所有日期
   */
  static getWeekDays(weekNum: number): Day[][] {
    // 获取当前日期
    const CURRENT_DATE = new Date();
    // 获取当前日期是本周的周几（0-6，其中0代表周日，1代表周一，以此类推）
    const WEEK_DAY = CURRENT_DATE.getDay();
    // 计算并设置目标周的第一天(周日)的日期
    const BEGIN_DATE = new Date(CURRENT_DATE.getTime() - WEEK_DAY * Constants.TOTAL_MILLISECONDS_IN_DAY +
      (Constants.DAYS_IN_WEEK * weekNum) * Constants.TOTAL_MILLISECONDS_IN_DAY);
    let days: CalendarData[] = [];
    let week: Day[] = [];
    const CALENDAR: Day[][] = [];
    let i18nCalendar: i18n.Calendar = i18n.getCalendar('zh-Hans', 'chinese');
    for (let i = 0; i < Constants.DAYS_IN_WEEK; i++) {
      const DAY = new Date(BEGIN_DATE.getTime() + i * Constants.TOTAL_MILLISECONDS_IN_DAY);
      days[i] = {
        year: DAY.getFullYear(),
        month: DAY.getMonth() + 1,
        date: DAY.getDate(),
      };
      // 设置日历对象内部的时间日期
      i18nCalendar.setTime(new Date(days[i].year, days[i].month - 1, days[i].date));
      week.push({
        dayNum: days[i].date,
        lunarDay: i18nCalendar.get('date') === 1 ? TimeUtils.lunarMonthToChinese(i18nCalendar.get('month') + 1) :
        TimeUtils.lunarDayToChinese(i18nCalendar.get('date')),
        dayInfo: new DayInfo(days[i].year, days[i].month, days[i].date,
          TimeUtils.getWeekDayStr(days[i].year, days[i].month, days[i].date)),
        // isShowSchedulePoint: CommonData.SCHEDULE_ARRAY.includes(days[i].year + '/' + days[i].month + '/' +
        // days[i].date) ? true : false
      });
    }
    CALENDAR.push(week);
    return CALENDAR;
  }
}