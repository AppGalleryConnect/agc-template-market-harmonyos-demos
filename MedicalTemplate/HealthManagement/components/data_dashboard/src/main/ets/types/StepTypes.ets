/**
 * 步数数据相关类型定义
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
 * 步数统计数据
 */
export interface StepStatistics {
  total: number; // 总步数
  average: number; // 平均步数
  calories: number; // 消耗卡路里
  distance: number; // 距离（公里）
}

/**
 * 步数范围选项
 */
export interface StepRangeOption {
  label: string;
  period: string;
  currentSteps: number;
  steps: number[];
  labels: string[];
  statistics: StepStatistics;
}

/**
 * 简单菜单项
 */
export interface SimpleMenuItem {
  value: string;
  action: () => void;
}

/**
 * 步数历史记录项
 */
export interface StepHistoryItem {
  steps: number; // 步数
  duration: string; // 时长
  distance: number; // 距离（公里）
  dateTime: string; // 日期时间
}

/**
 * 月份分组
 */
export interface MonthGroup {
  monthTitle: string; // 月份标题
  records: StepHistoryItem[]; // 记录列表
}

/**
 * 步数历史统计数据
 */
export interface StepHistoryStatistics {
  totalDuration: number; // 总时长（小时）
  totalCount: number; // 总次数
  totalCalories: number; // 总消耗（千卡）
}

