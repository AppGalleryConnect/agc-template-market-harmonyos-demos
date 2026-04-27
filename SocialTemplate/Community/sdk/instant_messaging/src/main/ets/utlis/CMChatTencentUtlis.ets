import { buffer, util } from '@kit.ArkTS';

export class CMChatTencentUtlis {
  @Track map: Map<string, ArrayBuffer> = new Map()

  /**
   * 字符串转ArrayBuffer
   */
  static strToArrayBuffer(content: string) {
    try {
      return buffer.from(content, 'utf-8').buffer;
    } catch (err) {
      return new ArrayBuffer(0);
    }
  }

  /**
   * ArrayBuffer转字符串
   */
  static arrayBufferToStr(data: ArrayBuffer) {
    let textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeToString(new Uint8Array(data));
  }
}