
import { Logger } from '../logger/AppLogger';

const TAG = "PrototypeUtil"

export class PrototypeUtil {
  /**
   * 获取对象的所有方法（除构造）
   * @param obj 对象
   * @returns 方法列表
   */
  public static getObjectMethods(obj: object): string[] {
    try {
      if (obj) {
        return Object.getOwnPropertyNames(Object.getPrototypeOf(obj))
          .filter(prop => typeof Reflect.get(obj, prop) === 'function' && prop !== 'constructor');
      }
    } catch (e) {
      Logger.error(TAG, "getObjectMethods error")
    }
    return [];
  }

  /**
   * 反射调用对象的方法(保证对象上下文)
   * @param obj 对象
   * @param method 方法名称
   * @param params 参数
   * @returns 结果
   */
  public static invokeMethods(obj: any, method: string, params: any): any {
    if (obj && method) {
      if (obj[method]) {
        return obj[method](params);
      }
    }
    return undefined;
  }
}