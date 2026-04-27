import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 安全随机数工具类
 * 使用 cryptoFramework 生成安全的随机数，替代不安全的 Math.random()
 */
export class SecureRandomUtil {
  /**
   * 生成指定范围内的随机整数
   * @param max 最大值（不包含），例如 max=10 时，返回 0-9 之间的整数
   * @return 0 到 max-1 之间的随机整数
   */
  static getRandomIndex(max: number): number {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 自定义范围(0-max之内)
    let figure: number = randData.data[0] * max / 255;
    figure = Math.floor(figure);
    return figure;
  }

  /**
   * 生成 0 到 max 之间的随机数（浮点数）
   * @param max 最大值
   * @return 0 到 max 之间的随机浮点数
   */
  static getRandomFloat(max: number): number {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    // 生成 0 到 max 之间的随机数
    let figure: number = randData.data[0] * max / 255;
    return figure;
  }

  /**
   * 生成更大的随机数（通过组合多个字节）
   * @param max 最大值
   * @return 0 到 max 之间的随机数
   */
  static getRandomNumber(max: number): number {
    // 计算需要多少字节来表示 max

    let bytesRequired = Math.ceil(Math.log2(max) / 8);
    if (bytesRequired < 1) {
      bytesRequired = 1;
    }
    if (bytesRequired > 4) {
      bytesRequired = 4; // 限制最多4字节，避免过大
    }

    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(bytesRequired);

    // 将多个字节组合成一个数字
    let figure = 0;
    for (let i = 0; i < bytesRequired; i++) {
      figure = figure * 256 + randData.data[i];
    }

    // 映射到指定范围
    let maxValue = Math.pow(256, bytesRequired) - 1;
    figure = figure * max / maxValue;
    return figure;
  }

  /**
   * 生成随机字符串（类似 Math.random().toString(36)）
   * @param length 字符串长度
   * @return 随机字符串
   */
  static getRandomString(length: number): string {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    let result = '';
    for (let i = 0; i < length; i++) {
      let rand = cryptoFramework.createRandom();
      let randData = rand.generateRandomSync(1);
      let index = Math.floor(randData.data[0] * chars.length / 256);
      result += chars.charAt(index);
    }
    return result;
  }
}

