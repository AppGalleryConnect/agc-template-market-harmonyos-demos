

/**
 * 对象深拷贝
 *
 * @param obj 原始对象
 * @return cloned obj
 */
export function deepClone(obj): any {
  let copy;
  if (null === obj || "object" !== typeof obj) {
    return obj;
  }
  if (obj instanceof Array) {
    copy = [];
    for (let i = 0, len = obj.length; i < len; i++) {
      copy[i] = deepClone(obj[i]);
    }
    return copy;
  }
  if (obj instanceof Object) {
    copy = {};
    for (let attr in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, attr)) {
        copy[attr] = deepClone(obj[attr]);
      }
    }
  }
  return copy;
}

/**
 * 判断对象是否相等
 *
 * @param obj1 对象1
 * @param obj2 对象2
 * @return boolean 相等
 */
export function deepEqual(obj1: any, obj2: any): boolean {
  if (obj1 === obj2) {
    return true;
  }
  if (typeof obj1 !== 'object' || obj1 === null ||
    typeof obj2 !== 'object' || obj2 === null) {
    return false;
  }
  const keys1 = Object.keys(obj1);
  const keys2 = Object.keys(obj2);
  if (keys1.length !== keys2.length) {
    return false;
  }
  for (let key of keys1) {
    if (!keys2.includes(key) || !deepEqual(obj1[key], obj2[key])) {
      return false;
    }
  }
  return true;
}

/**
 * 类型转换，将string转换成boolean
 *
 * @param input 对象1
 * @return boolean 相等
 */
export function parseBoolean(input: string): boolean {
  if (input) {
    return input.toLowerCase() === 'true';
  }
  return false;
}

/**
 * 类型转换，将string转换成number
 *
 * @param input 对象1
 * @return boolean 相等
 */
export function parseNumber(input: string): number | undefined {
  if (input) {
    return Number(input);
  }
  return undefined;
}

/**
 * 类型转换，将Map转换成Record
 *
 * @param input 对象1
 * @return boolean 相等
 */
export function mapToObject(map: Map<string, any>): Record<string, any> {
  const obj: Record<string, any> = {};
  map.forEach((value, key) => {
    obj[key] = value;
  });
  return obj;
}
;