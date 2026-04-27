import display from '@ohos.display';
import { usbManager } from '@kit.BasicServicesKit';
import { i18n } from '@kit.LocalizationKit';
import { NFC_TYPE, Operation } from './Enum';
import { nfcCardInfo } from '../db/NfcCardInfo';

export default class Util {
  /**
   * 去掉浮点的小数
   */
  public static float2Int(value?: number): number {
    if (value === undefined || value === null) {
      return 0;
    }

    if (value < 0) {
      return Math.ceil(value);
    }
    return Math.floor(value);
  }

  /**
   * 屏幕高度(像素比屏幕密度)
   * @returns
   */
  public static screenHeight(): number {
    let defaultDisplay = display.getDefaultDisplaySync();
    let height = defaultDisplay.height / defaultDisplay.scaledDensity;

    if (isNaN(height)) {
      return 0;
    }
    return Util.float2Int(height);
  }

  /**
   * 屏幕宽度(像素比屏幕密度)
   * @returns
   */
  public static screenWeight(): number {
    let defaultDisplay = display.getDefaultDisplaySync();
    let width = defaultDisplay.width / defaultDisplay.scaledDensity;

    if (isNaN(width)) {
      return 0;
    }
    return Util.float2Int(width);
  }

  /**
   * 空字符串检查
   * @param value 检查的值
   * @returns true 为空
   */
  public static isEmpty(value?: string): boolean {
    if (value === undefined || value === null || value === '' || value.length <= 0) {
      return true;
    }
    return false;
  }

  public static isEmptyArray(array: Array<usbManager.USBDevice>): boolean {
    return (array.length === 0 ? true : false);
  }

  public static toHexString(d: number[]): string {
    if (!d || d.length === 0) {
      return '-';
    }
    let str: string = '';
    for (let i = 0; i < d.length; i++) {
      let tmp: string = d[i].toString(16);
      if (tmp.length === 1) {
        tmp = '0' + tmp;
      }
      str += tmp;
    }
    return str;
  }

  static HEX = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];

  public static toHexString2(d: number[], s: number, n: number): string {
    let ret: string = '';
    let e = s + n;

    for (let i = s; i < e; ++i) {
      let v = d[i];
      ret += Util.HEX[0x0F & (v >> 4)];
      ret += Util.HEX[0x0F & v];
    }
    return ret;
  }

  public static toInt(b: number[], s?: number, n?: number): number {
    if (!s) {
      s = 0;
    }
    if (!n) {
      n = b.length - s;
    }
    let e = s + n;
    let result: number = 0;
    for (let i = s; i < e; i++) {
      result <<= 8;
      result |= b[i] & 0xFF;
    }
    return result;
  }

  public static toIntR(b: number[], start?: number, end?: number): number {
    if (!start) {
      start = b.length - 1;
    }
    if (!end) {
      end = b.length;
    }
    let ret = 0;
    for (let i = start; (i >= 0 && end > 0); --i, --end) {
      ret <<= 8;
      ret |= b[i] & 0xFF;
    }
    return ret;
  }

  public static copyOf(bytes: number[], newLength: number): number[] {
    if (newLength > bytes.length) {
      let ret = [newLength];
      for (let i = 0; i < newLength; i++) {
        ret[i] = bytes[i];
      }
      return ret;
    } else {
      return bytes.slice(0, newLength);
    }
  }

  public static filterString(array: string[], item: string): string[] {
    let result: string[] = [];
    for (let arrayElement of array) {
      if (arrayElement !== item) {
        result.push(arrayElement);
      }
    }
    return result;
  }

  static hex2Bytes(hex: string): number[] {
    if (!(hex != null && hex.length % 2 === 0 && hex.match('[0-9A-Fa-f]+'))) {
      return [];
    }
    let len = hex.length;
    let data: number[] = [];
    for (let i = 0; i < len; i += 2) {
      data[i / 2] = ((parseInt(hex.charAt(i), 16) << 4) + parseInt(hex.charAt(i + 1), 16));
    }
    return data;
  }

  public static acBytesToACMatrix(acBytes: number[]): number[][] | undefined {
    if (acBytes === null) {
      return undefined;
    }

    let acMatrix: number[][] = [[], [], []];
    if (acBytes.length > 2 &&
      ((acBytes[1] >>> 4) & 0x0F) ===
        ((acBytes[0] ^ 0xFF) & 0x0F) &&
      (acBytes[2] & 0x0F) ===
        (((acBytes[0] ^ 0xFF) >>> 4) & 0x0F) &&
      ((acBytes[2] >>> 4) & 0x0F) ===
        ((acBytes[1] ^ 0xFF) & 0x0F)) {
      // C1, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[0].push(((acBytes[1] >>> 4 + i) & 0x01));
      }
      // C2, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[1].push(((acBytes[2] >>> i) & 0x01));
      }
      // C3, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[2].push(((acBytes[2] >>> 4 + i) & 0x01));
      }
      return acMatrix;
    }
    return undefined;
  }

  public static async getCardName(nfcType?: number, name?: string): Promise<string> {
    if (!name) {
      switch (nfcType) {
        case NFC_TYPE.NFC_TYPE_DOOR:
          name = '我的门禁卡';
          break;
        case NFC_TYPE.NFC_TYPE_BUS:
          name = '我的公交卡';
          break;
        case NFC_TYPE.NFC_TYPE_BIKE:
          name = '我的电动车卡';
          break;
        case NFC_TYPE.NFC_TYPE_ELEVATOR:
          name = '我的电梯卡';
          break;
        case NFC_TYPE.NFC_TYPE_BANK:
          name = '我的银行卡';
          break;
        default:
          name = '我的卡片';
          break;
      }
    }
    let index = 1;
    let tName = name;
    while ((await nfcCardInfo.findByName(name))) {
      name = tName + index++;
    }
    return name;
  }

  static isBlank(str: string | undefined | null): boolean {
    let length: number = 0;
    if (!str || (str === null) || ((length = str.length) === 0)) {
      return true;
    }
    for (let i = 0; i < length; i++) {
      if (false === Util.isBlankChar(str.charCodeAt(i))) {
        return false; //只要有一个非空字符即为非空字符串
      }
    }
    return true;
  }

  static isBlankChar(c: number): boolean {
    return Util.isWhitespace(c.toString()) ||
    Util.isSpaceChar(c.toString()) ||
      c === 0xFEFF || c === 0x202A || c === 0x0000;
  }

  /**
   * 判断字符串char是否是空格符
   * @param char
   * @returns
   */
  static isSpaceChar(char: string): boolean {
    return i18n.Unicode.isSpaceChar(char);
  }

  /**
   * 判断字符串char是否是空白符
   * @param char
   * @returns
   */
  static isWhitespace(char: string): boolean {
    return i18n.Unicode.isWhitespace(char);
  }

  static getFormatDateStr(date: number | string | Date, format?: string): string {
    date = Util.getFormatDate(date);
    if (!format || format === '') {
      format = 'yyyy-MM-dd HH:mm:ss'; //yyyy-MM-dd HH:mm:ss.fff
    }
    const year = date.getFullYear();
    const month = Util.padZero(date.getMonth() + 1);
    const day = Util.padZero(date.getDate());
    const hours = Util.padZero(date.getHours());
    const minutes = Util.padZero(date.getMinutes());
    const seconds = Util.padZero(date.getSeconds());
    let formattedDate = format.replace('yyyy', year.toString());
    formattedDate = formattedDate.replace('MM', month);
    formattedDate = formattedDate.replace('dd', day);
    formattedDate = formattedDate.replace('HH', hours);
    formattedDate = formattedDate.replace('mm', minutes);
    formattedDate = formattedDate.replace('ss', seconds);
    return formattedDate;
  }

  static padZero(num: number): string {
    return num.toString().padStart(2, '0');
  }

  static isNotBlank(str: string | undefined | null): boolean {
    return false === Util.isBlank(str);
  }

  static toNumber(value: string): number | string {
    try {
      let parsedValue = parseFloat(value);
      if (isNaN(parsedValue)) {
        return value;
      }
      if (parsedValue.toString().length !== value.length) {
        return value;
      }
      return parsedValue;
    } catch (e) {
      return value;
    }
  }

  static getFormatDate(date?: number | string | Date): Date {
    if (!date || date === null) { //无参数
      date = new Date();
    } else if (typeof date === 'string') { //字符串日期
      if (date.length === 0) {
        date = new Date();
      } else {
        if (date.toString().length === 10 || date.toString().length === 13) {
          date = Util.toNumber(date); //将字符串时间戳 转为 number
          if (typeof date === 'number') {
            date = new Date(date);
            return date;
          }
        }
        let dateStr = date.replaceAll('-', '/')
          .replace('年', '/')
          .replace('月', '/')
          .replace('日', ' ')
          .replace('  ', ' ')
          .replace('时', ':')
          .replace('分', ':')
          .replace('秒', '');
        date = new Date(dateStr);
      }
    } else if (typeof (date) === 'number') { //时间戳
      date = new Date(date);
    } else {
      date = new Date(date);
    }
    return date;
  }

  public static isKeyBReadable(c1: number, c2: number, c3: number): boolean {
    return c1 === 0 && ((c2 === 0 && c3 === 0) || (c2 === 1 && c3 === 0) || (c2 === 0 && c3 === 1));
  }

  public static getOperationRequirements(c1: number, c2: number, c3: number, op: Operation, isSectorTrailer: boolean,
    isKeyBReadable: boolean): number {
    if (isSectorTrailer) {
      if (op !== Operation.ReadKeyA && op !== Operation.ReadKeyB &&
        op !== Operation.ReadAC && op !== Operation.WriteKeyA &&
        op !== Operation.WriteKeyB && op !== Operation.WriteAC) {
        return 4;
      }
      if (c1 === 0 && c2 === 0 && c3 === 0) {
        if (op === Operation.WriteKeyA || op === Operation.WriteKeyB ||
          op === Operation.ReadKeyB || op === Operation.ReadAC) {
          return 1;
        }
        return 0;
      } else if (c1 === 0 && c2 === 1 && c3 === 0) {
        if (op === Operation.ReadKeyB || op === Operation.ReadAC) {
          return 1;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 0) {
        if (op === Operation.WriteKeyA || op === Operation.WriteKeyB) {
          return 2;
        }
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 0) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else if (c1 === 0 && c2 === 0 && c3 === 1) {
        if (op === Operation.ReadKeyA) {
          return 0;
        }
        return 1;
      } else if (c1 === 0 && c2 === 1 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        if (op === Operation.ReadKeyA || op === Operation.ReadKeyB) {
          return 0;
        }
        return 2;
      } else if (c1 === 1 && c2 === 0 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        if (op === Operation.WriteAC) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else {
        return -1;
      }
    } else {
      if (op !== Operation.Read && op !== Operation.Write && op !==
      Operation.Increment && op !== Operation.DecTransRest) {
        return -1;
      }
      if (c1 === 0 && c2 === 0 && c3 === 0) {
        return (isKeyBReadable) ? 1 : 3;
      } else if (c1 === 0 && c2 === 1 && c3 === 0) {
        if (op === Operation.Read) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 0) {
        if (op === Operation.Read) {
          return (isKeyBReadable) ? 1 : 3;
        }
        if (op === Operation.Write) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 0) {
        if (op === Operation.Read || op === Operation.DecTransRest) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 2;
      } else if (c1 === 0 && c2 === 0 && c3 === 1) {
        if (op === Operation.Read || op === Operation.DecTransRest) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 0;
      } else if (c1 === 0 && c2 === 1 && c3 === 1) {
        if (op === Operation.Read || op === Operation.Write) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 1) {
        if (op === Operation.Read) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 1) {
        return 0;
      } else {
        return -1;
      }
    }
  }
};