import { pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';

export class FormatUtil {
  static formatSecondsToMMSS(totalSeconds: number): string {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  public static formatFullDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();
    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());
    return `${year}${month}${day}${hours}${minutes}${seconds}`;
  }

  public static base64Encode(str: string) {
    const base64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    let result = '';
    let i = 0;

    while (i < str.length) {
      let char1 = str.charCodeAt(i++);
      let char2 = str.charCodeAt(i++);
      let char3 = str.charCodeAt(i++);

      let enc1 = char1 >> 2;
      let enc2 = ((char1 & 3) << 4) | (char2 >> 4);
      let enc3 = ((char2 & 15) << 2) | (char3 >> 6);
      let enc4 = char3 & 63;

      if (isNaN(char2)) {
        enc3 = enc4 = 64;
      } else if (isNaN(char3)) {
        enc4 = 64;
      }

      result +=
      base64Table.charAt(enc1) +
      base64Table.charAt(enc2) +
      base64Table.charAt(enc3) +
      base64Table.charAt(enc4);
    }

    return result;
  }

  public static getBase64String(str: string) {
    let originalString = str ? str : 'mini:mini';
    let base64String = FormatUtil.base64Encode(originalString);
    return base64String;
  }
}

// 剪贴板内容
export function copyText(text: string) {
  // 创建剪贴板内容对象
  try {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    // 获取系统剪贴板对象
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪贴板
    systemPasteboard.getData().then((data) => { // 读取剪贴板内容
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    })
  } catch (e) {
    UtilLog.error(`copyText failed with error ${JSON.stringify(e)}`);
  }
}