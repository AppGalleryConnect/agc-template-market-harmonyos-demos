/**
 * 周度报告类型定义
 */

/**
 * 周度报告数据
 */
export interface WeeklyReportData {
  // 日期范围
  startDate: string; // 开始日期，如 "2024年2月27日"
  endDate: string; // 结束日期，如 "03月02日"
  dateRange: string; // 日期范围显示，如 "2024年2月27日 - 03月02日"
  
  // 体重趋势
  weightTrend: WeightTrendData;
  
  // 体脂率趋势
  bodyFatTrend: BodyFatTrendData;
  
  // 血压数据
  bloodPressure: BloodPressureData;
  
  // 心率数据
  heartRate: HeartRateData;
}

/**
 * 体重趋势数据
 */
export interface WeightTrendData {
  maxWeight: number; // 最高体重（斤）
  minWeight: number; // 最低体重（斤）
  change: number; // 变化（斤）
  chartData: ChartDataPoint[]; // 图表数据点
}

/**
 * 体脂率趋势数据
 */
export interface BodyFatTrendData {
  maxBodyFat: number; // 最高体脂率（%）
  minBodyFat: number; // 最低体脂率（%）
  change: number; // 变化（%）
  chartData: ChartDataPoint[]; // 图表数据点
}

/**
 * 血压数据
 */
export interface BloodPressureData {
  systolic: number; // 收缩压平均值
  diastolic: number; // 舒张压平均值
  pulse: number; // 平均脉搏（可选）
}

/**
 * 心率数据
 */
export interface HeartRateData {
  maxHeartRate: number; // 最高心率
  minHeartRate: number; // 最低心率
  restingHeartRate: number; // 静息心率
  averageHeartRate: number; // 平均心率
}

/**
 * 图表数据点
 */
export interface ChartDataPoint {
  date: string; // 日期，如 "08/27"
  value: number; // 数值
}

