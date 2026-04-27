import { buffer } from '@kit.ArkTS';
import { aegis, SafeRandom } from '@hw-agconnect/petal-aegis';
import { UtilLog } from '@hw-agconnect/util-log';

let key = SafeRandom.ohAegRandomHex(16);
let keyUint8 = new Uint8Array()
try {
  keyUint8 = new Uint8Array(buffer.from(key, 'utf-8').buffer);
} catch (e) {
  UtilLog.error('Uint8Array error' + JSON.stringify(e))
}

export async function aesEncName(name: string): Promise<Uint8Array> {
  let plainText = name; //待加密内容
  let encryptText = await aegis.aesEncText(aegis.AESAlg.AES_CBC_PKCS7Padding, plainText, keyUint8);
  return encryptText
}

export async function aesDecName(encryptText: Uint8Array): Promise<string> {
  let decryptText = await aegis.aesDecText(aegis.AESAlg.AES_CBC_PKCS7Padding, encryptText, keyUint8);
  return decryptText
}