import { FormatUtil } from './FormatUtil';
import { i18n } from '@kit.LocalizationKit';
import { CommonConstants } from '../constants/CommonContants';

export class DateUtils {
  public static YEAR: string = 'year';
  public static MONTH: string = 'month';
  public static DATE: string = 'date';
  public static LUNAR_MONTH =
    new Map([['0', '正月'], ['1', '二月'], ['2', '三月'], ['3', '四月'], ['4', '五月'], ['5', '六月'], ['6', '七月'],
      ['7', '八月'], ['8', '九月'], ['9', '十月'], ['10', '十一月'], ['11', '十二月']]);
  public static LUNAR_DAY =
    new Map([['1', '初一'], ['2', '初二'], ['3', '初三'], ['4', '初四'], ['5', '初五'], ['6', '初六'], ['7', '初七'],
      ['8', '初八'], ['9', '初九'], ['10', '初十']
      , ['11', '十一'], ['12', '十二'], ['13', '十三'], ['14', '十四'], ['15', '十五'], ['16', '十六'], ['17', '十七'],
      ['18', '十八'], ['19', '十九'], ['20', '廿十']
      , ['21', '廿一'], ['22', '廿二'], ['23', '廿三'], ['24', '廿四'], ['25', '廿五'], ['26', '廿六'], ['27', '廿七'],
      ['28', '廿八'], ['29', '廿九'], ['30', '三十']]);

  public static isToday(day: string): boolean {
    return FormatUtil.formatDate(new Date()) === day;
  }

  public static getCurrentYear(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.YEAR);
  }

  public static getCurrentMonth(): number {
    let calendar = i18n.getCalendar('en-US');
    return calendar.get(DateUtils.MONTH);
  }

  public static getCurrentLunarYear(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.YEAR);
  }

  public static getCurrentLunarMonth(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.MONTH);
  }

  public static getCurrentLunarDay(): number {
    let calendar = i18n.getCalendar('zh-Hans', 'chinese');
    return calendar.get(DateUtils.DATE);
  }

  public static isCurrentMonth(year: number, month: number) {
    return year === DateUtils.getCurrentYear() && month === DateUtils.getCurrentMonth();
  }

  public static getCurrentLunarDayDesc(year: number, month: number, day: number,
    descConverter?: (lunarMonth: number, lunarDay: number) => string | undefined) {
    let calendar = i18n.getCalendar('en-US');
    let today = new Date(calendar.getTimeInMillis());
    calendar.setTime(new Date(today.getFullYear(), today.getMonth(), today.getDate()));
    let diffDays: number = calendar.compareDays(new Date(year, month, day));
    let lunarCalendar = i18n.getCalendar('zh-Hans', 'chinese');
    lunarCalendar.add(DateUtils.DATE, diffDays);
    let lunarDay = lunarCalendar.get(DateUtils.DATE);
    let lunarMonth = lunarCalendar.get(DateUtils.MONTH);
    if (descConverter) {
      return descConverter(lunarMonth, lunarDay);
    }
    if (lunarDay === 1) {
      return DateUtils.LUNAR_MONTH.get(lunarMonth + '')
    }
    return DateUtils.LUNAR_DAY.get(lunarDay + '')
  }

  public static getLunarMonthDesc(year: number, month: number, day: number) {
    let calendar = i18n.getCalendar('en-US');
    let today = new Date(calendar.getTimeInMillis());
    calendar.setTime(new Date(today.getFullYear(), today.getMonth(), today.getDate()));
    let diffDays: number = calendar.compareDays(new Date(year, month, day));
    let lunarCalendar = i18n.getCalendar('zh-Hans', 'chinese');
    lunarCalendar.add(DateUtils.DATE, diffDays);
    return DateUtils.LUNAR_MONTH.get(lunarCalendar.get(DateUtils.MONTH) + '')
  }
}