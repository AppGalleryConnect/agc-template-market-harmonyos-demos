import { SecureRandomUtil } from 'base_apis';
import { SignUtils } from './SignUtils';

export class OrderInfoUtil {
  static readonly APP_ID = '2014100900013222';
  static totalAmount = 0.01;
  /**
   *  pkcs8 格式的商户私钥。
   *
   * 	如下私钥，本 Demo 将优先
   * 	使用 RSA2_PRIVATE。RSA2_PRIVATE 可以保证商户交易在更加安全的环境下进行，建议商户使用
   * 	RSA2_PRIVATE。
   *
   * 	建议使用支付宝提供的公私钥生成工具生成和获取 RSA2_PRIVATE。
   * 	工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
   */
  static readonly RSA2_PRIVATE = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCaqhogAySiFiRQhE6nOd4PPw0sWJUmShJRFtaJajzxM4oLv2Vsjf3zregw5bzSB2R1UBqXJ/8eKMje5AGS8AaiuNH5yX/xj2qzFMYD8Bdd4NgCioskKYmzI4n1F83ekDVoJmexecG0JGGSa70LUGwLJmgcvPAMIVynULBpm/q3/hih1q7Y5FoO5+4U8IQ2EJrjcDPCot0CnMO1VRBkXdau3k0hLio+QjmhHqJDdLs3SJFJubyTGkg5EeY8Rd74f7eYlFHZyeSwbSgdzfImKy/6oe2uFiFzAi/SwY0rom83htz4vC4+PhI3/I/HnFuvmSLdQwGE8NLsGyMMyEKwXsdLAgMBAAECggEBAIY/nEmpMMUYnxDcp0D0M9HcEt0pTt1bcia8wh+o/ZkH+Y1U5v6hCYvYqjC3WXydOg+yJkKKTyGomSMPmmYmvjvEXU6KHupYaG9lWrPUVRQBtL4P79LF02aRNJBvxxym5BSxMVSVsRNieOcVaZRGjGHpRnmbbmm5E6mPmnExGSFWrbj/E3QaP/YYizfVt2n05Ulg+uXfh1nKuLDR6cN4i8V8Ban5kcF7elpdWQ4MDx2AHCIEGJzQEkpjTr3Z9ohiF5YwVLaFtDn1wzGGj+zhwj/0AhGvDEJR+ukXQgKT/hH28AhRkT7qwV4dJbwZLSVo3Ljo45EFWii7oZ4iIuvMRvECgYEA0YNnmFSyGkg2bkHX0EIBAiUImi0ly3YqjQG6aSbCRgU5Z/Oq5/K/5OXgY+QphQwgLtgW7kglRBtkG6lpncrh0PO1L1PuPsEdxHQahX1FCk8syGDNLlQ/0CG6b5tcgxs9sdTfPpgfqsbes9uq0ZMLDhMCdgWq5730h2VbzVdB/KcCgYEAvPs4dk/cJoTxV7eDz8+t/8VQ2sLrwnlBwMeXZsg7N/aJNGQMyYNZ9Kb5t35+TU0+9+VakweahUCe1iJQw4e+m9cIEumJQ31D739IZwl3YebwwgTs3cPRTM3Bqbp57I08rQdusQWDvSrUaoBUd4gus+j/20J2Pu3ciqvTdHLGwL0CgYBZls8dnFnsUySzUQRv0UmNGTjsdJHMxuK7GRoVDLXWKzW49cEHHg5gWsvw6we2FNFONqjXi5Ij5XKRQYggKTkWmJ/JdSJTQ1DvSJZurnpvRhvoMzyJqwz+eu21+8E7btKa0GQF6Bbid9eTIUOSCkaX5hkPTq0eG2QM4ZK347Ab0QKBgCS4M4pZjg81+abvk38HfWmbL1CyWxjYcrxAi9x+v3LqRlKVth5ZlVsCLrdGrsfaYIfOWsEC0zVdDv/Qfxze/VxOddUm53LjnhWlB65tmnK9ar5oMpYMfFiOCjkucI5UCxwbu5hN2AEjl05yTPdE0L5IYZ561Xr4wMd5B4cy3geJAoGAPMMtZiYweJWj37gtfvnh7HdJq2x/0q7zAPmAiK+5sK9yblUiwxOw0AaGypkbcKrW/sOTdRnqwfXb77u4rQUaUk7LH0qza9lPMniObW/RDRq7eQsr0J8mvxsf4aMfzfO7CdBzT6+igtmiLErMMWTwnhf9GC52/FVRV30ymxDDZdM=';

  static async getOrderInfo(): Promise<string> {
    const keyValues = OrderInfoUtil.buildOrderParamMap();
    let orderParam = OrderInfoUtil.buildOrderParam(keyValues);
    let sign = await OrderInfoUtil.getSign(keyValues);
    return orderParam + '&sign=' + sign;
  }

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

  static buildOrderParamMap(): Map<string, string> {
    const keyValues = new Map<string, string>()
    keyValues.set('app_id', OrderInfoUtil.APP_ID);
    // 不能包含中文，否则加密会有问题。。。。。。。。。。。。
    keyValues.set('biz_content', `{"timeout_express":"30m","product_code":"QUICK_MSECURITY_PAY","total_amount":"${OrderInfoUtil.totalAmount}","subject":"1","body":"xxx","out_trade_no":"${OrderInfoUtil.getOutTradeNo()}"}`);
    OrderInfoUtil.totalAmount = OrderInfoUtil.totalAmount + 0.01;
    keyValues.set('charset', 'utf-8');
    keyValues.set('method', 'alipay.trade.app.pay');
    keyValues.set('sign_type', 'RSA2');
    keyValues.set('timestamp', '2016-07-29 16:55:53');
    keyValues.set('version', '1.0');
    return keyValues;
  }

  static getOutTradeNo() {
    let date = new Date();
    let key = (date.getMonth().toString() + date.getDate().toString() + date.getHours().toString() + date.getMinutes()
      .toString() + date.getSeconds().toString()).toString();
    let r = SecureRandomUtil.getRandomNumber(10000000);
    key = key + r;
    key = key.substring(0, 15);
    return key;
  }
}