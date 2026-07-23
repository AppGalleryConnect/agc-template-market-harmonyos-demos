import { Constants } from './Constants';

export class CommonUtils {
  static weekFormat = new Intl.DateTimeFormat('zh-CN', { weekday: 'short' });

  /**
   * 格式化时间，2020.02.12 周三 12:00:00
   * @param dateTime
   */
  public static handleDateTime(dateTime: number) {
    const date = new Date(dateTime);
    const dateStr =
      `${date.getFullYear()}.${CommonUtils.padStart(date.getMonth() + 1)}.${CommonUtils.padStart(date.getDate())}`;
    const weekStr = CommonUtils.weekFormat.format(date);
    const timeStr =
      `${CommonUtils.padStart(date.getHours())}:${CommonUtils.padStart(date.getMinutes())}:${CommonUtils.padStart(date.getSeconds())}`;

    return `${dateStr} ${weekStr} ${timeStr}`;
  }


  /**
   * 数字，不足两位补零
   * @param value
   * @returns
   */
  public static padStart(value: number): string {
    return value.toString().padStart(2, '0');
  }

  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: string): number {
    return Reflect.get(Constants.GRID_MARGIN, bp);
  }
}