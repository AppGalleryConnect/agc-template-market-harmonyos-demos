import { AppStorageV2 } from '@kit.ArkUI';
import { CheckInInfo, DateModel } from '../model/DateModel';
import { getMonthDate } from './Time';

@ObservedV2
export class CalendarUtil {
  static _checkInInfo: CheckInInfo = AppStorageV2.connect(CheckInInfo, 'CheckInInfo', () => new CheckInInfo())!;

  public static getStartDate(): DateModel {
    return CalendarUtil._checkInInfo.startDate;
  }

  public static getEndDate(): DateModel {
    return CalendarUtil._checkInInfo.endDate;
  }

  public static getNight(): number {
    return CalendarUtil._checkInInfo.night;
  }

  public static getCurrentDate(): DateModel {
    return CalendarUtil._checkInInfo.currentDate;
  }

  public static setStartDate(startDate: DateModel) {
    CalendarUtil._checkInInfo.startDate = startDate;
  }

  public static setEndDate(endDate: DateModel) {
    CalendarUtil._checkInInfo.endDate = endDate;
  }

  public static setNight(night: number) {
    CalendarUtil._checkInInfo.night = night;
  }

  public static setCurrentDate(currentDate: DateModel) {
    CalendarUtil._checkInInfo.currentDate = currentDate;
  }

  public static formatDate(value: number) {
    return value < 10 ? value.toString().padStart(2, '0') : value;
  }

  public static getFormatDate(date: DateModel): string | undefined {
    return `${date.year}-${CalendarUtil.formatDate(date.month)}-${CalendarUtil.formatDate(date.day)}`;
  }

  public static getDayCount(startDate: DateModel, endDate: DateModel) {
    let count: number = 0;
    if (endDate.month === startDate.month) {
      count = endDate.day - startDate.day;
    } else if (endDate.month > startDate.month) {
      let startMonthday = getMonthDate(startDate.year, startDate.month);
      count += ((startMonthday.filter((item) => item !== 0).length) - startDate.day);
      count += endDate.day - 1;
    }
    return count;
  }
}