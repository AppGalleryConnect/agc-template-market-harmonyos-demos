/*
 * 完整关系链数据 - 合并各类关系链数据
*/
import { KinshipMap } from '../model/Data';

let mapData: KinshipMap = {}

export function setMapData(data: KinshipMap) {
  mapData = data
}

export function getMapData() {
  return mapData
}
