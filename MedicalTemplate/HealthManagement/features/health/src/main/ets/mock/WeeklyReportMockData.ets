/**
 * 周度报告 Mock 数据
 */
import { WeeklyReportData } from '../types/WeeklyReportTypes';

export const WEEKLY_REPORT_DATA: WeeklyReportData = {
  startDate: '2025年2月24日',
  endDate: '03月02日',
  dateRange: '2025年2月24日 - 03月02日',

  weightTrend: {
    maxWeight: 122,
    minWeight: 120,
    change: -0.2,
    chartData: [
      { date: '02/24', value: 110 },
      { date: '02/25', value: 145 },
      { date: '02/26', value: 115 },
      { date: '02/27', value: 120 },
      { date: '02/28', value: 140 },
      { date: '03/01', value: 125 },
      { date: '03/02', value: 118 }
    ]
  },

  bodyFatTrend: {
    maxBodyFat: 32.1,
    minBodyFat: 28.1,
    change: -4.0,
    chartData: [
      { date: '02/24', value: 20.2 },
      { date: '02/25', value: 30.5 },
      { date: '02/26', value: 16.8 },
      { date: '02/27', value: 25.5 },
      { date: '02/28', value: 30.1 },
      { date: '03/01', value: 12.2 },
      { date: '03/02', value: 31.1 }
    ]
  },

  bloodPressure: {
    systolic: 128,
    diastolic: 88,
    pulse: 0 // 暂无数据
  },

  heartRate: {
    maxHeartRate: 96,
    minHeartRate: 68,
    restingHeartRate: 76,
    averageHeartRate: 82
  }
};

