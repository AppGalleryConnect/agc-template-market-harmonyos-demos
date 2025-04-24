import { Logger } from './Logger';

const TAG: string = '[FormatUtil]';

export class FormatUtil {
  public static readonly DATE_YYYY_MM_DD = 'YYYY-MM-DD';
  public static readonly DATE_YYYY_MM_DD_24H_mm_ss = 'YYYY-MM-DD HH:mm:ss';
  public static readonly DATE_YYYY_MM_DD_24H_mm = 'YYYY-MM-DD HH:mm';
  public static readonly DATE_24H_mm_ss = 'HH:mm:ss';
  public static readonly DATE_24H_mm = 'HH:mm';

  public static formatDate(date: Date, format?: string) {
    if (!format) {
      format = FormatUtil.DATE_YYYY_MM_DD;
    }
    let year: string = date.getFullYear().toString();
    let month = String(date.getMonth() + 1).padStart(2, '0');
    let day = String(date.getDate()).padStart(2, '0');
    let hour = String(date.getHours()).padStart(2, '0');
    let minute = String(date.getMinutes()).padStart(2, '0');
    let second = String(date.getSeconds()).padStart(2, '0');
    return format.replace('YYYY', year)
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hour)
      .replace('mm', minute)
      .replace('ss', second);
  }

  public static formatTime(date: Date): string {
    return FormatUtil.formatDate(date, FormatUtil.DATE_24H_mm_ss);
  }

  public static dateTimeAppendZero(value: number): string {
    let v = value + 1;
    return v < 10 ? '0' + v : '' + v;
  }

  public static formatImgResource(str: string): string {
    if (!str.length) {
      return '';
    }
    if (str.startsWith('mockImage://')) {
      const resourceName = str.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(TAG, 'get image resource failed', err);
      }
    }
    return str;
  }
}