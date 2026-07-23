function padZero(input: number) {
  return input.toString().padStart(2, '0');
}

/**
 * 通用Utils
 */
export class CommonUtil {
  /**
   * 号码中间四位隐藏
   * @param phoneNo
   * @returns
   */
  public static encryptPhoneNo(phoneNo: string): string {
    if (phoneNo && phoneNo.length === 11) {
      const str = phoneNo.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
      return str
    }
    return phoneNo
  }

  /**
   * 时间戳转换成xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime: number | string | Date | undefined, format = 'YYYY-MM-DD') {
    if (!datetime) {
      return '';
    }
    let targetDate = datetime instanceof Date ? datetime : new Date(datetime);
    const month = targetDate.getMonth();
    const formats: Record<string, string | number> = {
      // 年份
      'YYYY': targetDate.getFullYear(),
      'YY': targetDate.getFullYear().toString().slice(-2),
      // 月份
      'MM': padZero(month + 1),
      // 日期
      'DD': padZero(targetDate.getDate()),
      // 时间
      'HH': padZero(targetDate.getHours()),
      'hh': padZero(targetDate.getHours() % 12 || 12),
      'mm': padZero(targetDate.getMinutes()),
      'ss': padZero(targetDate.getSeconds()),
    }
    return format.replace(/\[([^\]]+)]|Y{2,4}|M{1,4}|D{1,2}|H{1,2}|h{1,2}|m{1,2}|s{1,2}/g,
      (match: string, escaped: string): string => escaped || formats[match].toString())
  }
}
