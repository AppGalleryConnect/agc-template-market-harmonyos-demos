import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Pay, stringToUint8ArrayWithEncoder, uint8ArrayToStringWithDecoder } from '@cashier_alipay/cashiersdk';

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
          hilog.debug(0, 'Index', `SignUtils result resolve`);
          resolve(uint8ArrayToStringWithDecoder(result));
        }).catch((error: BusinessError) => {
          hilog.debug(0, 'Index', `SignUtils result reject error ${error.message} code ${error.code}`);
          reject(error.message);
        });

      }).catch((error: BusinessError) => {
        hilog.debug(0, 'Index', `SignUtils result reject error ${error.message} code ${error.code}`);
        reject(error.message);
      });
    });
  }
}

export class OrderInfoUtil {
  /**
   * 商户应用id
   */
  static readonly APP_ID = '';
  static totalAmount = 0.01;
  /**
   *  pkcs8 格式的商户私钥。
   *
   *  如下私钥，本 Demo 将优先
   *  使用 RSA2_PRIVATE。RSA2_PRIVATE 可以保证商户交易在更加安全的环境下进行，建议商户使用
   *  RSA2_PRIVATE。
   *
   *  建议使用支付宝提供的公私钥生成工具生成和获取 RSA2_PRIVATE。
   *  工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
   */
  // 请使用工具生成的私钥
  static readonly RSA2_PRIVATE = '';

  static buildOrderParam(keyValues: Map<string, string>): string {
    let param = '';
    keyValues.forEach((value, key) => {
      param += key + '=' + encodeURIComponent(value) + '&';
    });
    param = param.substring(0, param.length - 1);
    return param;
  }

  static async getSign(keyValues: Map<string, string>): Promise<string> {
    let mapEntries = Array.from(keyValues.keys());
    mapEntries.sort((a, b) => {
      return a[0].localeCompare(b[0]);
    });
    let sortedKeyValues = new Map<string, string>();
    mapEntries.forEach(entry => {
      sortedKeyValues.set(entry[0], entry[1]);
    });
    let param = '';
    keyValues.forEach((value, key) => {
      param += key + '=' + value + '&';
    });
    param = param.substring(0, param.length - 1);
    let oriSign = await SignUtils.sign(param, OrderInfoUtil.RSA2_PRIVATE);
    return encodeURIComponent(oriSign);
  }
}

export const apiPay = new Pay()