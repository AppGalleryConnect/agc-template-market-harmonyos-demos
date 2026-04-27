

import { util } from '@kit.ArkTS';


const TAG = 'CryptoUtil';
const DEFAULT_HKS_KEY_ALIAS: string = "DEFAULT_HKS_KEY_ALIAS";


export class CryptoUtil {
  private constructor() {
  }

  public static async huksAesGCMEncrypt(plaintext: string): Promise<Uint8Array> {
    let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
    let ciphertextBytes = plaintextBytes //await AegHuks.ohAegHuksEnc(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
    return ciphertextBytes;
  }

  public static async huksAesGCMEncryptHex(plaintext: string): Promise<string> {
    let plaintextBytes = new util.TextEncoder().encodeInto(plaintext);
    //let ciphertextHex = await AegHuks.ohAegHuksEncHex(DEFAULT_HKS_KEY_ALIAS, plaintextBytes);
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
