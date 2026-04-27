
import util from '@ohos.util';

export class TextDecoderUtils {
  /**
   * 将ArrayBuffer转换为字符串
   * @param buffer ArrayBuffer数据
   * @param encoding 编码格式，默认utf-8
   * @returns 解码后的字符串
   */
  static arrayBufferToString(buffer: ArrayBuffer, encoding: string = 'utf-8'): string {
    if (!buffer) {
      return '';
    }

    // 创建Uint8Array视图
    let uint8Array = new Uint8Array(buffer);

    // 使用TextDecoder进行解码
    let textDecoder = util.TextDecoder.create(encoding, { ignoreBOM: true });
    return textDecoder.decodeToString(uint8Array);
  }

}
