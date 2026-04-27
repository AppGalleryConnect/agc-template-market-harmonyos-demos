// 导入鸿蒙工具库
import { util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 随机字符生成工具类
 * 功能：从26个英文字母和10个数字中随机生成指定长度的字符串
 */
export class RandomGenerator {
  // 定义字符池：26个大写字母 + 26个小写字母 + 10个数字
  private static readonly CHAR_POOL: string =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
      'abcdefghijklmnopqrstuvwxyz' +
      '0123456789';

  /**
   * 生成随机4位字符
   * @returns 4位随机字符组成的字符串
   */
  static generateRandom4Digits(): string {
    let result: string = '';
    const poolLength: number = RandomGenerator.CHAR_POOL.length;

    // 生成4位随机字符
    for (let i = 0; i < 4; i++) {
      let rand = cryptoFramework.createRandom();
      // 设置生成随机数的字节长度为1
      let randData = rand.generateRandomSync(1);
      // 生成随机索引
      const randomIndex: number = Math.floor(randData.data[0] * poolLength / 255);
      // 从字符池中获取对应字符
      result += RandomGenerator.CHAR_POOL.charAt(randomIndex);
    }

    return result;
  }

  /**
   * 生成指定长度的随机字符
   * @param length 需要生成的字符长度
   * @returns 指定长度的随机字符字符串
   */
  static generateRandomString(length: number): string {
    if (length <= 0) {
      return '';
    }

    let result: string = '';
    const poolLength: number = RandomGenerator.CHAR_POOL.length;

    for (let i = 0; i < length; i++) {
      let rand = cryptoFramework.createRandom();
      // 设置生成随机数的字节长度为1
      let randData = rand.generateRandomSync(1);
      // 自定义范围(0-10之内)
      let tmpRandom: number = randData.data[0] / 255;
      const randomIndex: number = Math.floor(tmpRandom * poolLength);
      result += RandomGenerator.CHAR_POOL.charAt(randomIndex);
    }

    return result;
  }

  /**
   * 使用鸿蒙安全随机数生成器（适用于安全要求高的场景）
   * @param length 需要生成的字符长度
   * @returns 指定长度的随机字符字符串
   */
  static generateSecureRandomString(length: number): string {
    if (length <= 0) {
      return '';
    }

    let result: string = '';
    const poolLength: number = RandomGenerator.CHAR_POOL.length;

    // 使用鸿蒙的UUID生成器作为随机源（更安全）
    const uuid: string = util.generateRandomUUID();

    for (let i = 0; i < length; i++) {
      // 从UUID中提取字符作为随机种子
      const uuidChar: string = uuid.charAt(i % uuid.length);
      const seed: number = uuidChar.charCodeAt(0);
      const randomIndex: number = (seed + i) % poolLength;
      result += RandomGenerator.CHAR_POOL.charAt(randomIndex);
    }

    return result;
  }
}