export interface RealTimeInfo {
  icon: ResourceStr
  item: string,
  count: number
}

export enum RealTimeItem {
  CURRENT_VISITOR = '当前游客数',
  PARKING_SPACE = '景区停车位数量',
}

export enum TouristRestriction {
  CURRENT_DAY_VISITOR = '当日累计游客数',
  CURRENT_DAY_MAX_VISITOR = '当日最大承载量',
  INSTANT_MAX_VISITOR = '瞬时最大承载量',
}