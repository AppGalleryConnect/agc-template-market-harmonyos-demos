import { DateModel } from '../model/DateModel';
import { getMonthDate } from './Time';

@ObservedV2
export class CalenderUtil {
  public static getStartDate(): DateModel | undefined {
    return AppStorage.get('startDate');
  }

  public static getEndDate(): DateModel | undefined {
    return AppStorage.get('endDate');
  }

  public static getNight(): number | undefined {
    return AppStorage.get('night');
  }

  public static getCurrentDate(): DateModel | undefined {
    return AppStorage.get('currentDate');
  }

  public static formatDate(value: number) {
    return value < 10 ? value.toString().padStart(2, '0') : value;
  }

  public static getFormatDate(date: DateModel): string | undefined {
    return `${date.year}-${CalenderUtil.formatDate(date.month)}-${CalenderUtil.formatDate(date.day)}`;
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