import { util } from '@kit.ArkTS';
export class ObjectUtil {
  /**
   * 获取对象的Hash值。如果是第一次获取，则计算Hash值并保存到对象的Hash域（返回随机的Hash值）；如果不是第一次获取，则从Hash域中获取并返回Hash值（同一对象多次返回值保持不变）。
   * @param object
   * @returns
   */
  static getHash(object: object): number {
    return util.getHash(object);
  }

  /**
   * 判断对象是否为空
   * @param source
   * @returns
   */
  static isNull(source: object|undefined) {
    return source === undefined || source === null;
  }

  /**
   * 判断对象是否为空
   * @param source
   * @returns
   */
  static isNotNull(source: object|undefined) {
    return source !== undefined && source !== null;
  }

  /**
   * 通过key获取对象值
   * @param obj
   * @param key
   * @returns
   */
  static getValue<T>(obj: object, key: string): T {
    return obj[key] as T;
  }
}