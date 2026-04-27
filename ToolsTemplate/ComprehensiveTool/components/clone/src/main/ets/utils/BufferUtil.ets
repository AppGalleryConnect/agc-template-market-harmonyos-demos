import { UtilLog } from '@hw-agconnect/util-log';
import { buffer, util } from '@kit.ArkTS';

export class BufferUtil {
  static arrayBufferToBase64(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    const helper = new util.Base64Helper();
    return helper.encodeToStringSync(uint8Array);
  }

  // Base64转ArrayBuffer（鸿蒙版本）
  static base64ToArrayBuffer(base64: string): ArrayBuffer {
    const helper = new util.Base64Helper();
    const uint8Array = helper.decodeSync(base64);
    return uint8Array.buffer;
  }

  // ArrayBuffer合并
  static mergeArrayBuffer(startData: ArrayBuffer, endData: ArrayBuffer) {
    // 计算总长度
    const totalLength = startData.byteLength + endData.byteLength;
    // 创建新ArrayBuffer
    const mergedBuffer = new ArrayBuffer(totalLength);
    // 使用Uint8Array视图操作数据
    const mergedUint8 = new Uint8Array(mergedBuffer);
    mergedUint8.set(new Uint8Array(startData), 0); // 复制第一个Buffer到起始位置
    mergedUint8.set(new Uint8Array(endData), startData.byteLength); // 复制第二个Buffer到偏移位置
    return mergedBuffer;
  }

  static stringToArrayBuffer(str: string): ArrayBuffer | null {
    let buf: ArrayBuffer | null = null
    try {
      buf = buffer.from(str).buffer
    } catch (e) {
      UtilLog.error(`createPixelMap failed with error ${JSON.stringify(e)}`);
    }
    return buf;
  }
}