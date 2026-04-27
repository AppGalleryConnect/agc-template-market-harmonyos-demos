/**
 * @fileType: common
 * @zhName: 字符串工具类
 */
export class StringUtils {
  static isEmpty(obj: string | undefined | null): boolean {
    if (!obj) {
      return true
    }
    if (obj.length === 0) {
      return true;
    }
    return false;
  }

  static parseNumber(input: string, defValue?: number): number {
    if (!input) {
      return defValue ?? 0
    }
    const parsedInt = Number(input)
    if (!isNaN(parsedInt)) {
      return parsedInt
    } else {
      return defValue ?? 0
    }
  }

  static parseInt(input?: string, defValue?: number): number {
    if (!input) {
      return defValue ?? 0
    }
    let parsedInt = Number.parseInt(input)
    if (!isNaN(parsedInt)) {
      return parsedInt
    } else {
      return defValue ?? 0
    }
  }
}