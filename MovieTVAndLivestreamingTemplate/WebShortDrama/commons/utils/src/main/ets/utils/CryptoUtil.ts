

import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';


const TAG = 'CryptoUtil';
const DEFAULT_HKS_KEY_ALIAS: string = "DEFAULT_HKS_KEY_ALIAS";


export class CryptoUtil {
  private constructor() {
  }

  public static async huksAesGCMEncrypt(plaintext: string): Promise<Uint8Array> {
    try {
      let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
      let ciphertextBytes = plaintextBytes //await AegHuks.ohAegHuksEnc(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
      return ciphertextBytes;
    } catch (e) {
      hilog.error(0x0000, TAG, `huksAesGCMEncrypt failed: ${e}`);
      return new Uint8Array(0);
    }
  }

  public static async huksAesGCMEncryptHex(plaintext: string): Promise<string> {
    try {
      let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
      //let ciphertextHex = await AegHuks.ohAegHuksEncHex(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
    } catch (e) {
      hilog.error(0x0000, TAG, `huksAesGCMEncryptHex failed: ${e}`);
    }
    return '';
  }

  public static async huksAesGCMDecrypt(ciphertextBytes: Uint8Array): Promise<string> {
    /* let plaintextBytes = await AegHuks.ohAegHuksDec(DEFAULT_HKS_KEY_ALIAS, ciphertextBytes);
     let plaintext = util.TextDecoder.create().decodeWithStream(plaintextBytes);*/
    return '';
  }

  public static async huksAesGCMDecryptHex(ciphertextHex: string): Promise<string> {
    /* let plaintextBytes = await AegHuks.ohAegHuksDec(DEFAULT_HKS_KEY_ALIAS, ciphertextHex);
     let plaintext = util.TextDecoder.create().decodeWithStream(plaintextBytes);*/
    return '';
  }
}
