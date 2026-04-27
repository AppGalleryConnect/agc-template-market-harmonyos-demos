import { geoLocationManager } from '@kit.LocationKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';

/**
 * 通用Utils
 */
export class CommonUtil {
  /**
   * 对象赋值
   * @param target
   * @param source
   * @returns
   */
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  public static formatFullDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());

    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

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
    let geocodeRequest: geoLocationManager.GeoCodeRequest = { 'description': position, 'maxItems': 1 };
    let data: geoLocationManager.GeoAddress[] = []
    try {
      data = await geoLocationManager.getAddressesFromLocationName(geocodeRequest);
    } catch (err) {
      Logger.error('errCode:' + err.code + ', message:' + err.message);
    }
    return data
  }
}
