import dayjs from 'dayjs';
import isYesterday from 'dayjs/plugin/isYesterday';

dayjs.extend(isYesterday);

/**
 * 通用方法类
 */
export class Utils {
  /**
   * 格式化日期
   * @param dateTimeStamp
   * @returns
   */
  public static formatDate(dateTimeStamp: number): string {
    const target = dayjs(dateTimeStamp);
    return target.format('YYYY-MM-DD');
  }
}