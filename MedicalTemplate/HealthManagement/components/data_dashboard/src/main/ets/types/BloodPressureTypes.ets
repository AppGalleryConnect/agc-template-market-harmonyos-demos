/**
 * 血压数据相关类型定义
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
 * 血压统计数据
 */
export interface BloodPressureStatistics {
  avgSystolic: number; // 平均收缩压
  avgDiastolic: number; // 平均舒张压
  avgPulse: number; // 平均脉搏
}

/**
 * 血压范围选项
 */
export interface BloodPressureRangeOption {
  label: string;
  period: string;
  currentSystolic: number;
  currentDiastolic: number;
  systolicValues: number[];
  diastolicValues: number[];
  labels: string[];
  tooltipLabels?: string[]; // 弹窗显示的标签（日期范围）
  statistics: BloodPressureStatistics;
}

/**
 * 简单菜单项
 */
export interface SimpleMenuItem {
  value: string;
  action: () => void;
}

/**
 * 血压历史记录项
 */
export interface BloodPressureHistoryItem {
  systolic: number; // 收缩压
  diastolic: number; // 舒张压
  pulse: number; // 脉搏
  status: string; // 状态
  dateTime: string; // 日期时间
}

/**
 * 月份分组
 */
export interface MonthGroup {
  monthTitle: string;
  records: BloodPressureHistoryItem[];
}

