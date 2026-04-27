export enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

// 吉他弦信息
export interface GuitarInfo {
  note: string,
  freq: number,
  filePath: string,
  icon: ResourceStr,
  activeIcon: ResourceStr
}

// 轨迹点
export interface Point {
  x: number,
  y: number
}