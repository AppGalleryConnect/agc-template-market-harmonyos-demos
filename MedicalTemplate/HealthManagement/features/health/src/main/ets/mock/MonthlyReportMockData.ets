/**
 * 月度报告模拟数据
 */
import { MonthlyReportData } from '../types/MonthlyReportTypes';

export const MONTHLY_REPORT_DATA: MonthlyReportData = {
  startDate: '2025年4月1日',
  endDate: '4月30日',
  dateRange: '2025年4月',

  weightTrend: {
    maxWeight: 122,
    minWeight: 120,
    change: -0.2,
    chartData: [
      { date: '4/4', value: 110 },
      { date: '4/12', value: 145 },
      { date: '4/19', value: 105 },
      { date: '4/26', value: 110 },
      { date: '5/2', value: 125 }
    ]
  },

  bodyFatTrend: {
    maxBodyFat: 32.1,
    minBodyFat: 28.1,
    change: -4.0,
    chartData: [
      { date: '4/4', value: 15.5 },
      { date: '4/12', value: 28.1 },
      { date: '4/19', value: 32.8 },
      { date: '4/26', value: 16.2 },
      { date: '5/2', value: 24.1 }
    ]
  },

  bloodPressure: {
    diastolic: 88,
    systolic: 128,
    pulse: 0 // 暂无数据
  },

  heartRate: {
    restingHeartRate: 76,
    averageHeartRate: 82,
    maxHeartRate: 96,
    minHeartRate: 68
  }
};

