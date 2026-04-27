/*
 * 缓存数据
*/
import { KinshipMap } from '../model/Data';

let cacheData: KinshipMap = {};

export function setCacheData(main: KinshipMap) {
  let hash: KinshipMap = main
  const keys = Object.keys(hash)
  keys.forEach((key) => {
    const names = hash[key]
    names.forEach((name) => {
      if (!cacheData[name]) {
        cacheData[name] = [];
      }
      cacheData[name].push(key);
    });
  })
}

export function getCacheData() {
  return cacheData
}