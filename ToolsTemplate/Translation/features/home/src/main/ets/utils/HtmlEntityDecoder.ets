/**
 * HTML实体解码工具类
 */
export class HtmlEntityDecoder {
  /**
   * 解码HTML实体（包括基本实体和数字实体）
   * @param text 需要解码的文本
   * @returns 解码后的文本
   */
  static decode(text: string): string {
    let result = text;

    // 1. 解码基本HTML实体
    result = result
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&apos;/g, "'");

    // 2. 解码十进制数字实体
    result = result.replace(/&#(\d+);/g, (_match: string, dec: string): string => {
      return String.fromCharCode(Number(dec));
    });

    // 3. 解码十六进制数字实体
    result = result.replace(/&#x([0-9a-fA-F]+);/g, (_match: string, hex: string): string => {
      return String.fromCharCode(parseInt(hex, 16));
    });

    return result;
  }
}
