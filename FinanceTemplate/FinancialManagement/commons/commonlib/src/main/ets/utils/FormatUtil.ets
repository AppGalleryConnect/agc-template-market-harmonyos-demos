import { CommonConstants } from '../constants/CommonContants';
import { RouterMap } from '../constants/CommonEnum';
import { RouterModule } from '../models/RouterModule';
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

  public static formatDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());

    return `${year}-${month}-${day}`;
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
    return CommonConstants.CLOUD_STORAGE_URL + str;
  }

  public static encryptPhoneNo(phoneNo: string): string {
    if (phoneNo && phoneNo.length === 11) {
      const str = phoneNo.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
      return str
    }
    return phoneNo
  }

  public static encryptBankCardNo(bankCardNo: string): string {
    if (bankCardNo && bankCardNo.length > 8) {
      const reg = /^(\d{4})(\d*)(\d{4})$/
      const str = bankCardNo.replace(reg, (a: string, b: string, c: string, d: string) => {
        return b + c.replace(/\d/g, '*') + d
      })
      return str
    } else {
      return bankCardNo
    }
  }

  public static getStateTitle(code: number): string {
    switch (code) {
      case 1:
        return '定投中'
      case 2:
        return '定投成功'
      case 3:
        return '定投失败'
      case 4:
        return '已终止'
      default:
        return '定投失败'
    }
  }

  public static getTransactionStateTitle(type: number, code: number): string {
    if (type === 2) {
      switch (code) {
        case 1:
          return '购买受理中'
        case 2:
          return '购买成功'
        case 3:
          return '购买失败'
        case 4:
          return '已终止'
        default:
          return '购买失败'
      }
    } else if (type === 3) {
      switch (code) {
        case 1:
          return '赎回受理中'
        case 2:
          return '赎回成功'
        case 3:
          return '赎回失败'
        case 4:
          return '已终止'
        default:
          return '赎回失败'
      }
    } else {
      return '已到期'
    }
  }

  public static getStateFontColor(code: number): string {
    switch (code) {
      case 1:
        return 'rgba(0,0,0,0.90)'
      case 2:
        return 'rgba(0,0,0,0.90)'
      case 3:
        return '#E84026'
      case 4:
        return 'rgba(0,0,0,0.90)'
      default:
        return 'rgba(0,0,0,0.90)'
    }
  }

  public static getTransactionStateFontColor(code: number): string {
    switch (code) {
      case 1:
        return '#C15F2F'
      case 2:
        return '#E4480C'
      case 3:
        return '#64BB5C'
      case 4:
        return 'rgba(0,0,0,0.90)'
      default:
        return 'rgba(0,0,0,0.90)'
    }
  }

  public static jumpToNext(router: RouterMap, param?: ESObject) {
    try {
      RouterModule.push({
        url: router,
        param
      });
    } catch (err) {
      Logger.error(TAG, 'jump to next page failed::' + JSON.stringify(err));
    }
  }
}
