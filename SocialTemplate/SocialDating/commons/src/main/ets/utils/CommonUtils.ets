import { intl } from '@kit.LocalizationKit';
import i18n from '@ohos.i18n';
import { Constants } from './Constants';
import { Decimal } from '@kit.ArkTS';

export class CommonUtils {
  static ID_NO_LEN = 18;
  static FACTORS = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
  static CHECK_CODES = ['1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'];
  static WAN = 10000;
  static YI = 100000000;

  static formatDateToMinutes(date: Date): string {
    let dateFormat2 = new intl.DateTimeFormat('zh-CN', { dateStyle: 'short', timeStyle: 'short' });
    return dateFormat2.format(date);
  }

  /**
   * 判断字符串char是否是数字
   * @param char
   * @returns
   */
  static isDigit(char: string): boolean {
    return i18n.Unicode.isDigit(char);
  }

  static isBlank(str: string | null | undefined): boolean {
    if (str == null || str === undefined || str === '') {
      return true;
    }
    return str.trim().length === 0;
  }

  static contains(str: string | null | undefined, subStr: string | null | undefined): boolean {
    if (str == null || str === undefined || str === '') {
      return false;
    }
    if (subStr == null || subStr === undefined || subStr === '') {
      return false;
    }
    return str.indexOf(subStr) >= 0;
  }

  static isBlankChar(c: number): boolean {
    return c === 0xFEFF || c === 0x202A || c === 0x0000 || CommonUtils.isSpaceChar(c.toString());
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

  static isValidIdCardNo(idNo: string): boolean {
    if (idNo.length !== CommonUtils.ID_NO_LEN) {
      return false;
    }
    if (!idNo.match(Constants.ID_CARD_NO_REGEX)) {
      return false;
    }
    let sum = 0;
    for (let i = 0; i < CommonUtils.ID_NO_LEN - 1; i += 1) {
      sum += parseInt(idNo.charAt(i)) * CommonUtils.FACTORS[i]
    }
    let checkCode: string = CommonUtils.CHECK_CODES[sum%11];
    return checkCode === idNo.charAt(CommonUtils.ID_NO_LEN - 1)
  }

  /**
   * 将数字按单位（个、万、亿）转换成可读性较好的数字， 转换成万时保留1位小数，转换成亿时保留2位小数
   *
   * @param count count
   * @returns str
   */
  static transCount(count: number): string {
    if (count < CommonUtils.WAN) {
      return count.toString();
    } else if (count < CommonUtils.YI) {
      let tmp = (count / CommonUtils.WAN).toFixed(1);
      return tmp + '万';
    } else {
      let tmp = (count / CommonUtils.YI).toFixed(2);
      return tmp + '亿';
    }
  }

  static generateNo(): number {
    return new Date().getTime() + Decimal.random().mul(1000).floor().toNumber();
  }
}
