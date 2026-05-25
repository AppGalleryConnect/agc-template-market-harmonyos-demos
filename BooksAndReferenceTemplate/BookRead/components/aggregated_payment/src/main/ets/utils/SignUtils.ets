import { stringToUint8ArrayWithEncoder, uint8ArrayToStringWithDecoder } from '@cashier_alipay/cashiersdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class SignUtils {
  static async sign(content: string, privateKey: string): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      let keyGenerator = cryptoFramework.createAsyKeyGenerator('RSA2048|PRIMES_2');
      let privateKeyBuffer = new util.Base64Helper().decodeSync(privateKey);
      let privateKeyBlob = new Uint8Array(privateKeyBuffer!);
      keyGenerator.convertKey(null, { data: privateKeyBlob }).then(async pubPair => {
        let signer = cryptoFramework.createSign('RSA2048|PKCS1|SHA256');
        signer.init(pubPair.priKey).then(async () => {
          let input: cryptoFramework.DataBlob = { data: stringToUint8ArrayWithEncoder(content) };
          try {
            let signature = await signer.sign(input);
            let result = await new util.Base64Helper().encode(signature.data);
            hilog.debug(0, 'SignUtils', `SignUtils result resolve`);
            resolve(uint8ArrayToStringWithDecoder(result));
          } catch (error) {
            console.error('SignUtils', ` signature error = ${JSON.stringify(error)}`)
          }
        }).catch((error: BusinessError) => {
          hilog.debug(0, 'SignUtils', `SignUtils result reject error ${error.message} code ${error.code}`);
          reject(error.message);
        });

      }).catch((error: BusinessError) => {
        hilog.debug(0, 'SignUtils', `SignUtils result reject error ${error.message} code ${error.code}`);
        reject(error.message);
      });
    });
  }
}