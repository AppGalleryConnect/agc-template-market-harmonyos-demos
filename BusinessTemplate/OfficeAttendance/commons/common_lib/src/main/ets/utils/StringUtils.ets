export class StringUtils {
  public static isBlank(str?: string) {
    if (str) {
      return str.trim() === ''
    }
    return true;
  }
}