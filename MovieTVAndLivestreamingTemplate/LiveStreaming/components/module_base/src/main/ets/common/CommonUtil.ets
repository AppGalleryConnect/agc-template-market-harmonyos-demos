import { geoLocationManager } from '@kit.LocationKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

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
      console.error('errCode:' + err.code + ', message:' + err.message);
    }
    return data
  }

  /**
   * 随机四位数
   * @param min
   * @param max
   * @returns
   */
  public static rand(min: number, max: number): number {
    return Math.floor((Math.random() * (max - min))) + min
  }

  /**
   * 剪贴板内容
   * @param text
   * @returns
   */
  public static copyText(text: string, context: UIContext) {
    try { // 创建剪贴板内容对象
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      // 获取系统剪贴板对象
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData); // 将数据放入剪贴板
      systemPasteboard.getData().then((data) => { // 读取剪贴板内容
        if (data) {
          context.getPromptAction().showToast({ message: '复制成功', alignment: Alignment.Center });
        } else {
          context.getPromptAction().showToast({ message: '复制失败', alignment: Alignment.Center });
        }
      })
    } catch (e) {
    }
  }
}
