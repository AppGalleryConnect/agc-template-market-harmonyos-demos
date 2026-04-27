import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import isToday from 'dayjs/plugin/isToday';
import isYesterday from 'dayjs/plugin/isYesterday';

dayjs.extend(relativeTime);
dayjs.extend(isToday);
dayjs.extend(isYesterday);

export class TimeUtils {
  /**
   * 格式化日期时间
   * @param date
   * @param format
   * @returns
   */
  static formatDate(date: string | number | Date | null | undefined, format: string = 'YYYY/MM/DD'): string {
    return dayjs(date).format(format);
  }

  /**
   * 获取相对时间
   * @param dateTimeStamp
   * @returns
   */
  static getDateDiff(dateTimeStamp: number): string {
    if (!dateTimeStamp || dateTimeStamp <= 0) {
      return '';
    }
    const now = dayjs();
    const target = dayjs(dateTimeStamp);
    if (target.isAfter(now)) {
      return '';
    }
    const diffSeconds = now.diff(target, 'second');
    if (diffSeconds < 60) {
      return '刚刚';
    }
    const diffMinutes = now.diff(target, 'minute');
    if (diffMinutes < 60) {
      return `${diffMinutes}分钟前`;
    }
    const diffHours = now.diff(target, 'hour');
    if (diffHours < 24) {
      return `${diffHours}小时前`;
    }
    if (target.isYesterday()) {
      return '昨天';
    }
    if (target.isSame(now.subtract(2, 'day'), 'day')) {
      return '前天';
    }
    if (target.isAfter(now.subtract(7, 'day'))) {
      const diffDays = now.diff(target, 'day');
      return `${diffDays}天前`;
    }
    return target.format('YYYY-MM-DD');
  }

  /**
   * 获取消息相对时间
   * @param dateTimeStamp
   */
  static handleMsgTimeDiff(dateTimeStamp: number): string {
    if (!dateTimeStamp) {
      return '';
    }

    let timeStamp = dayjs(dateTimeStamp).format('YYYY-MM-DD hh:mm')

    // 时间字符串转时间戳
    const time = new Date(timeStamp);
    const now = new Date();

    const isToday =
      time.getFullYear() === now.getFullYear() &&
        time.getMonth() === now.getMonth() &&
        time.getDate() === now.getDate();

    const isThisYear = time.getFullYear() === now.getFullYear()

    let result: string = '';
    if (isToday) {
      result = dayjs(time).format('HH:mm');
    } else if (isThisYear) {
      result = dayjs(time).format('MM-DD');
    } else {
      result = dayjs(time).format('YYYY-MM-DD');
    }

    return result;
  }
}