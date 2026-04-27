import { stringToUint8ArrayWithEncoder, uint8ArrayToStringWithDecoder } from '@cashier_alipay/cashiersdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

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
          let signature = await signer.sign(input);
          let result = await new util.Base64Helper().encode(signature.data);
          resolve(uint8ArrayToStringWithDecoder(result));
        }).catch((error: BusinessError) => {
          reject(error.message);
        });

      }).catch((error: BusinessError) => {
        reject(error.message);
      });
    });
  }
}