/**
 * 健康报告 Mock 数据
 */
import { HealthReportData, BMILevel } from '../types/HealthReportTypes';

/**
 * 健康报告数据
 */
// 注意：此 mock 数据已不再使用，HealthReportModel 现在从 HealthDataInputModel 和 PersonInfoModel 读取实际数据
export const HEALTH_REPORT_DATA: HealthReportData = {
  userName: '小萝卜',
  score: 89,
  percentile: 85,
  reportDate: '2024-11-07',
  weight: 75,
  height: 175,
  age: 30,
  bmi: 24.5,
  bmiLevel: BMILevel.NORMAL,
  bodyFat: 20.5,
  fatMass: 15.4,
  heartRate: 75,
  bloodPressureSystolic: 120,
  bloodPressureDiastolic: 80,
  bloodGlucose: 5.5,
  bmiTarget: 23.0,
  bmiAdvice: '您的体重在正常范围内，请继续保持健康的生活方式。'
};

