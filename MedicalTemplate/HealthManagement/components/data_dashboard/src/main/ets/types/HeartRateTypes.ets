/**
 * 心率数据相关类型定义
 */

/**
 * 时间范围枚举
 */
export enum TimeRange {
  WEEK = 'WEEK',
  MONTH = 'MONTH',
  THREE_MONTHS = 'THREE_MONTHS'
}

/**
 * 心率统计数据
 */
export interface HeartRateStatistics {
  avgHigh: number; // 最高心率
  avgLow: number; // 最低心率
  restingHigh: number; // 静息高心率
  restingLow: number; // 静息低心率
}

/**
 * 心率范围选项
 */
export interface HeartRateRangeOption {
  label: string;
  period: string;
  currentRange: string;
  ranges: Array<[number, number]>;
  labels: Array<string>;
  tooltipLabels?: Array<string>; // 弹窗显示的标签（完整日期范围）
  groupSizes?: Array<number>;
  statistics: HeartRateStatistics;
}

/**
 * 简单菜单项
 */
export interface SimpleMenuItem {
  value: string;
  action: () => void;
}

/**
 * 心率历史记录项
 */
export interface HeartRateHistoryItem {
  range: string; // 心率范围
  dateTime: string; // 日期时间
}

/**
 * 月份分组
 */
export interface MonthGroup {
  monthTitle: string;
  records: HeartRateHistoryItem[];
}

/**
 * 心率详情记录项
 */
export interface HeartRateRecord {
  value: string; // 心率值
  time: string; // 测量时间
}

