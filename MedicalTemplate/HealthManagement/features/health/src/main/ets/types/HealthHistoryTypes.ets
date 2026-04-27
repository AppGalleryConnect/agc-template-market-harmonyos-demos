/**
 * 健康历史记录类型定义
 */

/**
 * 健康历史记录项
 */
export interface HealthHistoryItem {
  id: string;              // 记录ID
  date: string;            // 日期（如"9月12日"）
  weight: number;          // 体重
  fullDate: string;        // 完整日期（如"2025年9月12日"）
  height: number;          // 身高
  age: number;             // 年龄
  bmi: number;             // BMI
  bodyFat: number;         // 体脂率
  fatMass: number;         // 脂肪重量
  heartRate: number;       // 心率
  bloodPressureSystolic: number;   // 收缩压
  bloodPressureDiastolic: number;  // 舒张压
  bloodGlucose: number;    // 血糖
}

/**
 * 月份分组
 */
export interface MonthGroup {
  month: string;           // 月份（如"2025年9月"）
  items: HealthHistoryItem[];
}


