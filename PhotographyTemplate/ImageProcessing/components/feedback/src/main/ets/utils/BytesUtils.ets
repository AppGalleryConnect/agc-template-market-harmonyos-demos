import { util } from '@kit.ArkTS';
import { UtilLog } from '@hw-agconnect/util-log';
import { StandardCharsets } from '../common/CustomTypes';

const textEncoder: util.TextEncoder = util.TextEncoder.create(StandardCharsets.UTF_8);

const textDecoder: util.TextDecoder = util.TextDecoder.create(StandardCharsets.UTF_8, {
  fatal: false, ignoreBOM: false,
});

const TAG = '[BytesUtils]';

export class BytesUtils {
  /**
   * 将输入字符串编码为 Uint8Array 对象。
   *
   * @returns 返回编码后的对象。
   * @see - https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-util#encodeinto9
   */
  public static encodeUtf8(str: string): Uint8Array {
    try {
      // 字符串为空时 encodeInto 将返回 undefined
      return textEncoder.encodeInto(str) ?? new Uint8Array();
    } catch (e) {
      UtilLog.error(TAG, 'Fail to encodeInto str, error: ' + JSON.stringify(e));
      return new Uint8Array();
    }
  }

  /**
   * 将 UTF-8 编码的 Uint8Array 解码为字符串。
   *
   * @returns 返回解码后的字符串。
   * @see - https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-util#decodetostring12
   */
  public static decodeUtf8(bytes: Uint8Array): string {
    try {
      return textDecoder.decodeToString(bytes, { stream: false });
    } catch (e) {
      UtilLog.error(TAG, 'Fail to decodeToString, error: ' + JSON.stringify(e));
      return '';
    }
  }
}
