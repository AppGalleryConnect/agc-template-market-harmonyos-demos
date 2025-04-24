import { intl } from '@kit.LocalizationKit';

export class DateUtils {
  static ONE_YEAR_MILLI_SEC = 365 * 24 * 60 * 60 * 1000;

  static getYearsBefore(age: number): Date {
    let newDate = new Date().getTime() - age * DateUtils.ONE_YEAR_MILLI_SEC;
    return new Date(newDate);

  }

  static formatDateToMinutes(date: Date): string {
    let dateFormat2 = new intl.DateTimeFormat('zh-CN', { dateStyle: 'short', timeStyle: 'short', hourCycle: 'h24' });
    return dateFormat2.format(date);
  }

  static formatDateToDay(date: Date): string {
    let dateFormat = new intl.DateTimeFormat('zh-CN', { dateStyle: 'short'});
    return dateFormat.format(date);
  }

  static formatDateToMmDd(date: Date): string {
    let dateFormat4 = new intl.DateTimeFormat('zh-CN', {month: 'short', day: 'long'});
    return dateFormat4.format(date);
  }


  static getAge(birthDate: string | null | undefined): number | null {
    if (birthDate != null && birthDate !== undefined && birthDate !== '') {
      let dateTmp = new Date(birthDate);
      return new Date().getFullYear() - dateTmp.getFullYear();
    }
    return null;
  }

  static formatDateStr(date: Date, format?: string): string {
    if (format === undefined || format === '') {
      format = 'yyyy-MM-dd'; //yyyy-MM-dd
    }
    let year = date.getFullYear(); //年份，例如 2024
    let month = DateUtils.padZero(date.getMonth() + 1); //月份，0-11，0 表示一月，11 表示十二月
    let day = DateUtils.padZero(date.getDate()); //日期，1-31
    let formattedDate = format.replace('yyyy', year.toString());
    formattedDate = formattedDate.replace('MM', month);
    formattedDate = formattedDate.replace('dd', day);
    return formattedDate;
  }

  /**
   * 补零操作
   * @param num
   * @returns
   */
  private static padZero(num: number): string {
    return num.toString().padStart(2, '0');
  }
}
