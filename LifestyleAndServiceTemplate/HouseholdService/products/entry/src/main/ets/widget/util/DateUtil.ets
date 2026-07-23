export class DateUtils {
  /**
   * 不足的补零
   * @param input
   * @returns
   */
  static padZero(input: number): string {
    return input.toString().padStart(2, '0');
  }

  /**
   * 时间戳转换月日时分xx-xx xx:xx
   * @param datetime
   */
  static formatDate(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${DateUtils.padZero(date.getMonth() + 1)}-${DateUtils.padZero(date.getDate())} ${DateUtils.padZero(
      date.getHours())}:${DateUtils.padZero(date.getMinutes())}`;
  }
}