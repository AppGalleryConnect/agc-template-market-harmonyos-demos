import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 安全随机数工具类
 * 使用 cryptoFramework 生成安全的随机数，替代不安全的 Math.random()
 */
export class RandomUtil {
  /**
   * 生成指定范围内的随机整数
   * @param max 最大值（不包含），例如 max=10 时，返回 0-9 之间的整数
   * @returns 0 到 max-1 之间的随机整数
   */
  static getRandom(max: number): number {
    try {
      let randomNumber = cryptoFramework.createRandom();
      // 设置生成随机数的字节长度为1
      let randData = randomNumber.generateRandomSync(1);
      // 自定义范围(0-max之内)
      let result: number = randData.data[0] * max / 255;
      result = Math.floor(result);
      return result;
    } catch (error) {
      return -1;
    }
  }
}

