import { Logger } from './Logger';

const TAG: string = '[FormatUtil]';

export class FormatUtil {
  public static formatDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());

    return `${year}年${month}月${day}日 `;
  }

  public static formatSimpleDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());

    return `${month}.${day}`;
  }

  public static formatFullTime(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  public static getWeekOfYear(date: Date) {
    const startOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date.getTime() - startOfYear.getTime()) / 86400000;
    const weekOfYear = Math.ceil((pastDaysOfYear + startOfYear.getDay() + 1) / 7);
    return weekOfYear;
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

  public static formatSecretPhone(phone: string) {
    if (phone) {
      return phone.substring(0, 3) + '****' + phone.substring(7);
    }
    return '';
  }
}