/**
 * 月度报告数据类型定义
 */

// 图表数据点
export interface ChartDataPoint {
  date: string;  // 日期，格式如 "12/4"
  value: number; // 数值
}

// 体重趋势数据
export interface WeightTrend {
  maxWeight: number;      // 最高体重
  minWeight: number;      // 最低体重
  change: number;         // 变化量
  chartData: ChartDataPoint[]; // 图表数据
}

// 体脂率趋势数据
export interface BodyFatTrend {
  change: number;         // 变化量
  chartData: ChartDataPoint[]; // 图表数据
  maxBodyFat: number;     // 最高体脂率
  minBodyFat: number;     // 最低体脂率
}

// 血压数据
export interface BloodPressureData {
  pulse: number;     // 脉搏
  systolic: number;  // 收缩压
  diastolic: number; // 舒张压
}

// 心率数据
export interface HeartRateData {
  restingHeartRate: number; // 静息心率
  maxHeartRate: number;     // 最高心率
  minHeartRate: number;     // 最低心率
  averageHeartRate: number; // 平均心率
}

// 月度报告完整数据
export interface MonthlyReportData {
  startDate: string;    // 开始日期
  endDate: string;      // 结束日期
  dateRange: string;    // 日期范围显示文字
  weightTrend: WeightTrend;
  bodyFatTrend: BodyFatTrend;
  bloodPressure: BloodPressureData;
  heartRate: HeartRateData;
}

