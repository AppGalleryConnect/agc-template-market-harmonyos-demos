/**
 * 健康历史记录 Mock 数据
 */
import { HealthHistoryItem, MonthGroup } from '../types/HealthHistoryTypes';

/**
 * 健康历史记录列表 - 4月数据
 */
export const HEALTH_HISTORY_DATA: HealthHistoryItem[] = [
  {
    id: '1',
    date: '4月28日',
    weight: 112.4,
    fullDate: '2025年4月28日',
    height: 167,
    age: 28,
    bmi: 23.2,
    bodyFat: 32.1,
    fatMass: 39.3,
    heartRate: 85,
    bloodPressureSystolic: 128,
    bloodPressureDiastolic: 88,
    bloodGlucose: 5.0
  },
  {
    id: '2',
    date: '4月25日',
    weight: 112.8,
    fullDate: '2025年4月25日',
    height: 167,
    age: 28,
    bmi: 23.3,
    bodyFat: 32.2,
    fatMass: 39.4,
    heartRate: 83,
    bloodPressureSystolic: 126,
    bloodPressureDiastolic: 86,
    bloodGlucose: 5.1
  },
  {
    id: '3',
    date: '4月22日',
    weight: 113.2,
    fullDate: '2025年4月22日',
    height: 167,
    age: 28,
    bmi: 23.4,
    bodyFat: 32.3,
    fatMass: 39.6,
    heartRate: 82,
    bloodPressureSystolic: 125,
    bloodPressureDiastolic: 85,
    bloodGlucose: 5.2
  },
  {
    id: '4',
    date: '4月18日',
    weight: 113.6,
    fullDate: '2025年4月18日',
    height: 167,
    age: 28,
    bmi: 23.5,
    bodyFat: 32.4,
    fatMass: 39.8,
    heartRate: 84,
    bloodPressureSystolic: 127,
    bloodPressureDiastolic: 87,
    bloodGlucose: 5.0
  },
  {
    id: '5',
    date: '4月15日',
    weight: 114.0,
    fullDate: '2025年4月15日',
    height: 167,
    age: 28,
    bmi: 23.6,
    bodyFat: 32.5,
    fatMass: 40.0,
    heartRate: 81,
    bloodPressureSystolic: 124,
    bloodPressureDiastolic: 84,
    bloodGlucose: 5.3
  },
  {
    id: '6',
    date: '4月12日',
    weight: 114.4,
    fullDate: '2025年4月12日',
    height: 167,
    age: 28,
    bmi: 23.7,
    bodyFat: 32.6,
    fatMass: 40.2,
    heartRate: 80,
    bloodPressureSystolic: 123,
    bloodPressureDiastolic: 83,
    bloodGlucose: 5.1
  }
];

/**
 * 按月份分组的历史记录
 */
export const HEALTH_HISTORY_GROUPS: MonthGroup[] = [
  {
    month: '2025年4月',
    items: HEALTH_HISTORY_DATA
  },
  {
    month: '2025年3月',
    items: [
      {
        id: '7',
        date: '3月30日',
        weight: 115.2,
        fullDate: '2025年3月30日',
        height: 167,
        age: 28,
        bmi: 23.9,
        bodyFat: 32.8,
        fatMass: 40.5,
        heartRate: 79,
        bloodPressureSystolic: 122,
        bloodPressureDiastolic: 82,
        bloodGlucose: 5.4
      },
      {
        id: '8',
        date: '3月25日',
        weight: 115.6,
        fullDate: '2025年3月25日',
        height: 167,
        age: 28,
        bmi: 24.0,
        bodyFat: 33.0,
        fatMass: 40.8,
        heartRate: 78,
        bloodPressureSystolic: 121,
        bloodPressureDiastolic: 81,
        bloodGlucose: 5.2
      },
      {
        id: '9',
        date: '3月20日',
        weight: 116.0,
        fullDate: '2025年3月20日',
        height: 167,
        age: 28,
        bmi: 24.1,
        bodyFat: 33.2,
        fatMass: 41.0,
        heartRate: 77,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        bloodGlucose: 5.3
      }
    ]
  },
  {
    month: '2025年2月',
    items: [
      {
        id: '10',
        date: '2月28日',
        weight: 116.8,
        fullDate: '2025年2月28日',
        height: 167,
        age: 28,
        bmi: 24.3,
        bodyFat: 33.5,
        fatMass: 41.5,
        heartRate: 76,
        bloodPressureSystolic: 119,
        bloodPressureDiastolic: 79,
        bloodGlucose: 5.5
      },
      {
        id: '11',
        date: '2月22日',
        weight: 117.2,
        fullDate: '2025年2月22日',
        height: 167,
        age: 28,
        bmi: 24.4,
        bodyFat: 33.8,
        fatMass: 41.8,
        heartRate: 75,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        bloodGlucose: 5.4
      }
    ]
  }
];


