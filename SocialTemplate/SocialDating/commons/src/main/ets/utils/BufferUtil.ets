import { util } from '@kit.ArkTS'

export class BufferUtil {
  static bufferToString(buffer: Uint8Array): string {
    let textDecoder = util.TextDecoder.create('utf-8', {
      ignoreBOM: true
    });
    let resultPut = textDecoder.decodeToString(buffer);
    return resultPut;
  }
}