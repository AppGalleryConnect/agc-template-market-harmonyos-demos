import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class RandomUtil {
  // 获取随机数
  static getRandomIndex(length: number) {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-length之内)
    let num: number = randData.data[0] * length / 256;
    num = Math.floor(num);
    return num;
  }
}


