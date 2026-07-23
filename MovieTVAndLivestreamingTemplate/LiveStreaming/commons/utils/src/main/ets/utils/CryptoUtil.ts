

import { util } from '@kit.ArkTS';
import { BusinessError } from '@ohos.base';


const TAG = 'CryptoUtil';
const DEFAULT_HKS_KEY_ALIAS: string = "DEFAULT_HKS_KEY_ALIAS";


export class CryptoUtil {
  private constructor() {
  }

  public static async huksAesGCMEncrypt(plaintext: string): Promise<Uint8Array> {
    try {
      let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
      // let ciphertextBytes = await AegHuks.ohAegHuksEnc(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
      let ciphertextBytes = plaintextBytes;
      return ciphertextBytes;
    } catch (error) {
      let err = error as BusinessError;
      console.error(`huksAesGCMEncrypt failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return new Uint8Array(0);
    }
  }

  public static async huksAesGCMEncryptHex(plaintext: string): Promise<string> {
    try {
      let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
      // let ciphertextHex = await AegHuks.ohAegHuksEncHex(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
      return '';
    } catch (error) {
      let err = error as BusinessError;
      console.error(`huksAesGCMEncryptHex failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return '';
    }
  }

  public static async huksAesGCMDecrypt(ciphertextBytes: Uint8Array): Promise<string> {
    try {
      // let plaintextBytes = await AegHuks.ohAegHuksDec(DEFAULT_HKS_KEY_ALIAS, ciphertextBytes);
      // let plaintext = util.TextDecoder.create().decodeWithStream(plaintextBytes);
      return '';
    } catch (error) {
      let err = error as BusinessError;
      console.error(`huksAesGCMDecrypt failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return '';
    }
  }

  public static async huksAesGCMDecryptHex(ciphertextHex: string): Promise<string> {
    try {
      // let plaintextBytes = await AegHuks.ohAegHuksDec(DEFAULT_HKS_KEY_ALIAS, ciphertextHex);
      // let plaintext = util.TextDecoder.create().decodeWithStream(plaintextBytes);
      return '';
    } catch (error) {
      let err = error as BusinessError;
      console.error(`huksAesGCMDecryptHex failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return '';
    }
  }
}
