import { CompassItem, MountainInfo } from '../model/Index';

export class Constants {
  public static SENSOR_INTERVAL = 10000000;
}

export const COMPASS_LIST: CompassItem[] = [
  new CompassItem(0,$r('app.media.compass_1')),
  new CompassItem(1,$r('app.media.compass_2')),
]

// 二十四山定义（每个山15度，中心点对准）
export const  TWENTY_FOUR_MOUNTAINS: MountainInfo[] = [
  { name: '壬', center: 345, start: 337.5, end: 352.5 }, // 壬山
  { name: '子', center: 0,   start: 352.5, end: 7.5 },   // 子山（正北）
  { name: '癸', center: 15,  start: 7.5,   end: 22.5 },  // 癸山
  { name: '丑', center: 30,  start: 22.5,  end: 37.5 },  // 丑山
  { name: '艮', center: 45,  start: 37.5,  end: 52.5 },  // 艮山
  { name: '寅', center: 60,  start: 52.5,  end: 67.5 },  // 寅山
  { name: '甲', center: 75,  start: 67.5,  end: 82.5 },  // 甲山
  { name: '卯', center: 90,  start: 82.5,  end: 97.5 },  // 卯山（正东）
  { name: '乙', center: 105, start: 97.5,  end: 112.5 }, // 乙山
  { name: '辰', center: 120, start: 112.5, end: 127.5 }, // 辰山
  { name: '巽', center: 135, start: 127.5, end: 142.5 }, // 巽山
  { name: '巳', center: 150, start: 142.5, end: 157.5 }, // 巳山
  { name: '丙', center: 165, start: 157.5, end: 172.5 }, // 丙山
  { name: '午', center: 180, start: 172.5, end: 187.5 }, // 午山（正南）
  { name: '丁', center: 195, start: 187.5, end: 202.5 }, // 丁山
  { name: '未', center: 210, start: 202.5, end: 217.5 }, // 未山
  { name: '坤', center: 225, start: 217.5, end: 232.5 }, // 坤山
  { name: '申', center: 240, start: 232.5, end: 247.5 }, // 申山
  { name: '庚', center: 255, start: 247.5, end: 262.5 }, // 庚山
  { name: '酉', center: 270, start: 262.5, end: 277.5 }, // 酉山（正西）
  { name: '辛', center: 285, start: 277.5, end: 292.5 }, // 辛山
  { name: '戌', center: 300, start: 292.5, end: 307.5 }, // 戌山
  { name: '乾', center: 315, start: 307.5, end: 322.5 }, // 乾山
  { name: '亥', center: 330, start: 322.5, end: 337.5 }  // 亥山
];