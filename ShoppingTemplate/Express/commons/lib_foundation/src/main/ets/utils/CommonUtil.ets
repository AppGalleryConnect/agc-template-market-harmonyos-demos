import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon, site } from '@kit.MapKit';
import { Decimal } from '@kit.ArkTS';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Logger } from './Logger';
import { Parcel } from '../model/Parcel';
import { STATUS_OPERATOR_MAP } from '../common/Constant';

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
   * 根据地址获取经纬度
   * @param position
   * @returns
   */
  public static async getAddressesFromLocationName(position: string) {
    let geocodeRequest: geoLocationManager.GeoCodeRequest = {
      'description': position,
      'maxItems': 1
    };
    let coord: mapCommon.LatLng | undefined;
    try {
      const location = await geoLocationManager.getAddressesFromLocationName(geocodeRequest);
      if (location[0].latitude && location[0].longitude) {
        coord = {
          latitude: location[0].latitude,
          longitude: location[0].longitude
        }
      }
      return coord;
    } catch (err) {
      Logger.error('errCode:' + err.code + ', message:' + err.message);
    }
    // 如果getAddressesFromLocationName失败，则再根据site接口查询经纬度，会有一点误差
    let params: site.GeocodeParams = {
      'query': position,
    };
    try {
      const geocode = await site.geocode(params);
      if (geocode.sites && geocode.sites.length > 0) {
        const siteLocation = geocode.sites[0];
        if (siteLocation.location) {
          coord = siteLocation.location
        }
      }
      return coord
    } catch (err) {
      Logger.error('errCode:' + err.code + ', message:' + err.message);
    }
    return coord;
  }

  /**
   * 坐标转换
   * @param wgs84Position
   * @returns
   */
  public static convertCoordinate(wgs84Position: mapCommon.LatLng): mapCommon.LatLng {
    return map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
  }

  /**
   * 剪贴板内容
   * @param text
   * @returns
   */
  public static copyText(text: string) {
    try {
      // 创建剪贴板内容对象
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      // 获取系统剪贴板对象
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData).then(() => {
        ToastDialog.showToast({ message: '复制成功' });
      }).catch((e: BusinessError) => {
        ToastDialog.showToast({ message: '复制失败' });
        Logger.error('[CommonUtil]', `pasteboard setData falied. error: ${JSON.stringify(e)}`)
      })
    } catch (e) {
      Logger.error('[CommonUtil]', `copy text falied. error: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 两个数字相加
   * @param {Number} 两个数字
   * */
  public static calcAdd(a: number, b: number) {
    let x: string | number;
    let y: string | number;
    let m: number;
    try {
      x = a.toString().split('.')[1].length;
    } catch (e) {
      x = 0;
    }
    try {
      y = b.toString().split('.')[1].length;
    } catch (e) {
      y = 0;
    }
    m = Math.pow(10, Math.max(x, y));
    return (a * m + b * m) / m;
  };
  /**
   * 两个数字相减
   * @param {Number} 两个数字
   * */
  public static calcSub(a: number, b: number) {
    let x: string | number;
    let y: string | number;
    let m: number;
    let n: number;
    try {
      x = a.toString().split('.')[1].length;
    } catch (e) {
      x = 0;
    }
    try {
      y = b.toString().split('.')[1].length;
    } catch (e) {
      y = 0;
    }
    m = Math.pow(10, Math.max(x, y));
    n = x >= y ? x : y;
    return ((a * m - b * m) / m).toFixed(n);
  };

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

  /**
   * 防抖
   * @param fn
   * @param delay
   */
  static debounce<T extends Array<ESObject>>(fn: (...args: T) => void, delay: number = 300) {
    let timer: number | undefined = undefined;
    return (...args: T) => {
      // 1. 如果定时器已存在，清空它
      if (timer !== undefined) {
        clearTimeout(timer);
      }
      // 2. 重新启动定时器
      timer = setTimeout(() => {
        fn(...args);
      }, delay);
    };
  }

  /**
   * 获取本周一零点时间戳
   * @returns number
   */
  static getMondayTimestamp(): number {
    const now = new Date();
    const day = now.getDay() || 7;
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day + 1);
    monday.setHours(0, 0, 0, 0);
    return monday.getTime();
  }

  /**
  * 解析上门取件时间
  * @returns string
  */
  static parsePickupTime(time: number): string {
    if (time) {
      const today = new Date();
      const base = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
      const target = new Date(time);
      const date = new Date(target.getFullYear(), target.getMonth(), target.getDate()).getTime();
      const diff = Math.floor((date - base) / 86400000);
      const tempY = CommonUtil.formatDate(time, 'YYYY-MM-DD');
      const tempH = CommonUtil.formatDate(time, 'HH');
      const preH = Number(tempH) - 1;
      const timePeriod = `${String(preH).padStart(2, '0')}:00 - ${tempH}:00`
      const dayTexts = ['今天', '明天', '后天'];
      if (dayTexts[diff]) {
        return `${dayTexts[diff]} ${timePeriod}`
      }
      return `${tempY} ${timePeriod}`;
    }
    return '';
  }

  /**
   * 生成范围内的随机数
   * @returns number
   */
  static getRandom(min: number = 0, max: number = 1, fix: number = 0) {
    const num = Number(Decimal.random()) * (max - min) + min;
    return Number(num.toFixed(fix));
  }

  /**
   * 处理描述信息
   * @returns string
   */
  static handleDes(des: string | undefined, parcel: Parcel): string {
    // 传入的描述模板是空的
    if (!des) {
      return '快件状态更新中';
    }
    // 获取操作人信息，并提供兜底数组防止 operatorInfo[0] 报错
    const operatorInfo: string[] = STATUS_OPERATOR_MAP.get(parcel.status) || ['工作人员', '12345678900'];
    try {
      return des
        .replace(/senderCity/g, parcel.senderCity || '')
        .replace(/receiverCity/g, parcel.receiverCity || '')
        .replace(/operatorName/g, operatorInfo[0] || '工作人员')
        .replace(/operatorPhone/g, operatorInfo[1] || '');
    } catch (e) {
      Logger.error('[CommonUtil]', `handleDes error: ${JSON.stringify(e)}`);
      return des;
    }
  }

  // 判断两个时间戳是否为同一天
  public static isSameDay(timeStampA: number, timeStampB: number): boolean {
    const dateA = new Date(timeStampA);
    const dateB = new Date(timeStampB);
    return dateA.getFullYear() === dateB.getFullYear() &&
      dateA.getMonth() === dateB.getMonth() &&
      dateA.getDate() === dateB.getDate();
  }
}
