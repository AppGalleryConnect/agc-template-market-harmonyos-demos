/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import hilog from '@ohos.hilog';

export class SafeJson {
  private static TAG = 'SafeJson';

  /**
   * 主动捕获JSON.parse异常，防止crash
   * @param inStr 待解析json字符串
   * @param reviver 对结果进行变换的函数。对象的每个成员都调用这个函数。
   * @returns json对象
   */
  public static parse(inStr: string, reviver?: (this: ESObject, key: string, value: ESObject) => ESObject): ESObject {
    try {
      if (reviver) {
        return JSON.parse(inStr, reviver);
      } else {
        return JSON.parse(inStr);
      }
    } catch (err) {
      hilog.error(0, SafeJson.TAG, 'agc safeJsonParse JSON.parse parse fail, err code: ' + err.code);
      return null;
    }
  }

  /**
   * 主动捕获JSON.stringify异常，防止crash
   * @param value 待解析json对象
   * @param replacer 字符串和数字的数组
   * @param space space向返回值JSON文本添加缩进、空白和换行字符，使其更易于阅读。
   * @returns json解析后的字符串
   */
  public static jsonStringifyArray(value: ESObject, replacer?: (number | string)[] | null,
    space?: string | number): string {
    try {
      if (replacer) {
        if (space) {
          return JSON.stringify(value, replacer, space);
        }
        return JSON.stringify(value, replacer);
      }
      if (space) {
        return JSON.stringify(value, null, space);
      }
      return JSON.stringify(value);
    } catch (err) {
      hilog.error(0, SafeJson.TAG, 'agc safeJsonStringifyArray JSON.stringify parse fail, err code: ' + err.code);
      return '';
    }
  }

  /**
   * 主动捕获JSON.stringify异常，防止crash
   * @param value 待解析json对象
   * @param replacer 对结果进行变换的函数
   * @param space space向返回值JSON文本添加缩进、空白和换行字符，使其更易于阅读。
   * @returns json解析后的字符串
   */
  public static jsonStringify(value: ESObject, replacer?: (this: ESObject, key: string, value: ESObject) => ESObject,
    space?: string | number): string {
    try {
      if (replacer) {
        if (space) {
          return JSON.stringify(value, replacer, space);
        }
        return JSON.stringify(value, replacer);
      }
      if (space) {
        return JSON.stringify(value, null, space);
      }
      return JSON.stringify(value);
    } catch (err) {
      hilog.error(0, SafeJson.TAG, 'agc safeJsonStringify JSON.stringify parse fail, err code: ' + err.code);
      return '';
    }
  }
}