/**
 * 健康报告相关类型定义
 */

/**
 * 健康指标项
 */
export interface HealthMetricItem {
  icon: ResourceStr;
  label: string;
  value: string;
  unit: string;
  backgroundColor: ResourceColor;
}

/**
 * BMI等级
 */
export enum BMILevel {
  LOW = 'low',        // 偏瘦
  NORMAL = 'normal',  // 正常
  HIGH = 'high',      // 偏胖
  OBESE = 'obese'     // 肥胖
}

/**
 * 健康报告数据
 */
export interface HealthReportData {
  userName: string;           // 用户名
  score: number;              // 健康评分
  percentile: number;         // 超越百分比
  reportDate: string;         // 报告日期
  weight: number;             // 体重
  height: number;             // 身高
  age: number;                // 年龄
  bmi: number;                // BMI
  bmiLevel: BMILevel;         // BMI等级
  bodyFat: number;            // 体脂率
  fatMass: number;            // 脂肪重量
  heartRate: number;          // 心率
  bloodPressureSystolic: number;  // 收缩压
  bloodPressureDiastolic: number; // 舒张压
  bloodGlucose: number;       // 血糖
  bmiTarget: number;          // BMI目标值
  bmiAdvice: string;          // BMI建议
}

/**
 * 报告类型菜单项
 */
export interface ReportMenuItem {
  label: string;
  value: string;
}

/**
 * 菜单项类型（用于bindMenu）
 */
export interface MenuItemType {
  value: string;
  action: () => void;
  disabled?: boolean;
}
