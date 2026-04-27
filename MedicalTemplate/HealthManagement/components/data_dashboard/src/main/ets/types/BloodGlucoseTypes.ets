/**
 * 血糖数据相关类型定义
 */

/**
 * 时间范围枚举
 */
export enum TimeRange {
  WEEK = 'week',
  MONTH = 'month',
  THREE_MONTHS = 'threeMonths'
}

/**
 * 血糖统计数据
 */
export interface BloodGlucoseStatistics {
  avgValue: number; // 平均血糖值
  minValue: number; // 最低值
  maxValue: number; // 最高值
}

/**
 * 血糖范围选项
 */
export interface BloodGlucoseRangeOption {
  label: string;
  period: string;
  currentValue: number;
  values: number[];
  labels: string[];
  tooltipLabels?: string[];
  statistics: BloodGlucoseStatistics;
}

/**
 * 简单菜单项
 */
export interface SimpleMenuItem {
  value: string;
  action: () => void;
}

/**
 * 血糖历史记录项
 */
export interface BloodGlucoseHistoryItem {
  value: number; // 血糖值
  status: string; // 状态（偏低、正常、偏高）
  mealTime: string; // 餐前/餐后
  dateTime: string; // 日期时间
}

/**
 * 月份分组
 */
export interface MonthGroup {
  monthTitle: string;
  records: BloodGlucoseHistoryItem[];
}

