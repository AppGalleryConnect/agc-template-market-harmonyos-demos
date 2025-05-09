export class DayFormat {
  date: Date;
  constructor(date: string | Date) {
    this.date = date instanceof Date ? date : new Date(date);
  }

  format(formatStr: string) {
    const pad = (num: number) => num.toString().padStart(2, '0');
    const month = this.date.getMonth();

    const formats: Record<string, string | number> = {
      // 年份
      'YYYY': this.date.getFullYear(),
      'YY': this.date.getFullYear().toString().slice(-2),
      // 月份
      'MM': pad(month + 1),
      // 日期
      'DD': pad(this.date.getDate()),

      // 时间
      'HH': pad(this.date.getHours()),
      'hh': pad(this.date.getHours() % 12 || 12),
      'mm': pad(this.date.getMinutes()),
      'ss': pad(this.date.getSeconds()),
    }

    return formatStr.replace(/\[([^\]]+)]|Y{2,4}|M{1,4}|D{1,2}|H{1,2}|h{1,2}|m{1,2}|s{1,2}/g,
      (match: string, escaped: string): string => escaped || formats[match].toString())
  }
}