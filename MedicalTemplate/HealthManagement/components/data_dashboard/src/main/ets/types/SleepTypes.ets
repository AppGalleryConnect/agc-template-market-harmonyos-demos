/**
 * 睡眠数据相关类型定义
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
 * 睡眠统计数据
 */
export interface SleepStatistics {
  avgDeepSleep: number; // 平均深睡（小时）
  avgDeepSleepMinute: number; // 平均深睡（分钟）
  avgLightSleep: number; // 平均浅睡（小时）
  avgLightSleepMinute: number; // 平均浅睡（分钟）
  avgREM: number; // 平均REM（分钟）
  avgAwake: number; // 平均清醒（分钟）
}

/**
 * 睡眠范围选项
 */
export interface SleepRangeOption {
  label: string;
  currentDate: string;
  totalHour: number;
  totalMinute: number;
  sleepData: Array<[number, number, number, number]>;
  labels: Array<string>;
  groupSizes?: Array<number>;
  statistics: SleepStatistics;
}

/**
 * 简单菜单项
 */
export interface SimpleMenuItem {
  value: string;
  action: () => void;
}

/**
 * 睡眠历史记录项
 */
export interface SleepHistoryItem {
  duration: string; // 时长
  dateTime: string; // 日期时间
}

/**
 * 月份分组
 */
export interface MonthGroup {
  monthTitle: string;
  records: SleepHistoryItem[];
}

/**
 * 睡眠记录项
 */
export interface SleepRecord {
  label: string;
  value: string;
}

