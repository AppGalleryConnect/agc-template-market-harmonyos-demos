import { CommonConstants } from '../constants/CommonContants';
import { Logger } from './Logger';

const TAG = '[FormatUtil]';

export class FormatUtil {
  public static salesDisplay(sales: number, step: number = 100): string {
    if (sales <= step) {
      return sales.toString();
    }
    const rounded = Math.floor(sales / step) * step;
    return `${rounded}+`;
  }

  public static distanceDisplay(distanceInMeters: number): string {
    if (distanceInMeters < 1000) {
      return `${distanceInMeters}m`;
    }
    const distanceInKilometers = (distanceInMeters / 1000).toFixed(2);
    return `${distanceInKilometers}km`;
  }

  public static commentCountDisplay(commentCount: number, limit: number = 9999): string {
    if (commentCount <= limit) {
      return commentCount.toString();
    } else {
      return `${limit}+`;
    }
  }

  public static dateAsISO(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 返回月日信息
  public static dateAsMD(date: Date): string {
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${month}-${day}`;
  }

  public static dateAsCustom(date: Date): string {
    const month = String(date.getMonth() + 1);
    const day = String(date.getDate());
    return `${month}月${day}日`;
  }

  public static formatFullDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  public static getImgResource(str: string): string {
    if (!str.length) {
      return '';
    }
    if (str.startsWith('mockImage://')) {
      const resourceName = str.split('//')[1];
      try {
        const str = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return str;
      } catch (err) {
        Logger.error(TAG, 'get image resource failed', err);
      }
    }
    return str;
  }
}
