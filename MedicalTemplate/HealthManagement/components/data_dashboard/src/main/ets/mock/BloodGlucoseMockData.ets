/**
 * 血糖页面 Mock 数据
 */
import {
  TimeRange as BloodGlucoseTimeRange,
  BloodGlucoseRangeOption,
  MonthGroup as BloodGlucoseMonthGroup
} from '../types/BloodGlucoseTypes';

/**
 * 血糖范围选项数据
 * @export
 */
export const BLOOD_GLUCOSE_RANGE_OPTIONS: Record<BloodGlucoseTimeRange, BloodGlucoseRangeOption[]> = {
  [BloodGlucoseTimeRange.WEEK]: [
    {
      label: '2025年04月24日 - 04月30日',
      period: '04月24日(周日)',
      currentValue: 5.0,
      values: [3.0, 5.0, 7.0, 3.5, 5.5, 8.0, 4.0],
      labels: [],
      statistics: { avgValue: 5.0, minValue: 3.0, maxValue: 8.0 }
    },
    {
      label: '2025年02月17日 - 02月23日',
      period: '02月20日(周四)',
      currentValue: 4.8,
      values: [4.6, 5.1, 4.8, 4.9, 5.0, 4.7, 5.2],
      labels: [],
      statistics: { avgValue: 4.9, minValue: 2.8, maxValue: 5.2 }
    }
  ],
  [BloodGlucoseTimeRange.MONTH]: [
    {
      label: '2025年4月',
      period: '04月19日',
      currentValue: 5.0,
      values: [6.8, 3.5, 5.2, 3.0, 4.9, 7.2, 4.7, 5.1, 3.8, 6.2, 4.3, 5.5, 4.1, 6.0, 3.7, 5.8, 4.6, 5.3, 3.9, 6.1, 4.4,
        5.7, 4.2, 5.9, 3.6, 6.3, 4.8, 5.4, 4.0, 5.6],
      labels: ['4/1', '4/2', '4/3', '4/4', '4/5', '4/6', '4/7', '4/8', '4/9', '4/10', '4/11', '4/12', '4/13', '4/14',
        '4/15', '4/16', '4/17', '4/18', '4/19', '4/20', '4/21', '4/22', '4/23', '4/24', '4/25', '4/26', '4/27', '4/28',
        '4/29', '4/30'],
      statistics: { avgValue: 4.9, minValue: 3.0, maxValue: 7.2 }
    },
    {
      label: '2025年3月',
      period: '03月15日',
      currentValue: 4.8,
      values: [4.7, 4.9, 5.0, 4.8, 5.1, 4.6, 5.2, 4.9, 5.0, 4.8, 4.7, 5.1, 4.9],
      labels: ['3/2', '', '3/10', '', '3/17', '', '3/24', '', '3/31', '', '', '', ''],
      statistics: { avgValue: 4.9, minValue: 2.9, maxValue: 5.2 }
    }
  ],
  [BloodGlucoseTimeRange.THREE_MONTHS]: [
    {
      label: '2025年2月 - 04月',
      period: '3月平均值',
      currentValue: 5.0,
      values: [4.6, 3.8, 5.2, 4.8, 5.0, 6.8, 4.5, 5.1, 7.2, 3.5, 6.5, 4.9],
      labels: ['', '2月', '', '', '', '3月', '', '', '', '4月', '', ''],
      tooltipLabels: ['2月1日～2月7日', '2月8日～2月14日', '2月15日～2月21日', '2月22日～2月28日', '3月1日～3月7日',
        '3月8日～3月14日', '3月15日～3月21日', '3月22日～3月28日', '4月1日～4月7日', '4月8日～4月14日', '4月15日～4月21日',
        '4月22日～4月28日'],
      statistics: { avgValue: 5.1, minValue: 3.5, maxValue: 7.2 }
    },
    {
      label: '2023年10月 - 12月',
      period: '11月平均值',
      currentValue: 4.9,
      values: [5.0, 4.8, 4.9, 5.1, 4.7, 5.2, 4.8, 5.0],
      labels: ['', '10月', '', '11月', '', '', '12月', ''],
      tooltipLabels: ['10月1日～10月10日', '10月11日～10月20日', '11月1日～11月10日', '11月11日～11月20日',
        '11月21日～11月30日', '12月1日～12月10日', '12月11日～12月20日', '12月21日～12月31日'],
      statistics: { avgValue: 4.9, minValue: 2.8, maxValue: 5.2 }
    }
  ]
};

/**
 * 血糖历史记录数据
 * @export
 */
export const BLOOD_GLUCOSE_HISTORY_MONTHS: BloodGlucoseMonthGroup[] = [
  {
    monthTitle: '2025年4月',
    records: [
      {
        value: 5.0,
        status: '正常',
        mealTime: '晚餐后',
        dateTime: '04/28 19:00'
      },
      {
        value: 4.8,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '04/25 13:30'
      },
      {
        value: 5.2,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '04/22 09:00'
      },
      {
        value: 6.5,
        status: '偏高',
        mealTime: '晚餐后',
        dateTime: '04/18 19:30'
      },
      {
        value: 4.5,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '04/15 13:00'
      },
      {
        value: 5.1,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '04/12 09:15'
      },
      {
        value: 3.8,
        status: '偏低',
        mealTime: '晚餐前',
        dateTime: '04/08 18:20'
      },
      {
        value: 4.9,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '04/05 13:45'
      }
    ]
  },
  {
    monthTitle: '2025年3月',
    records: [
      {
        value: 5.2,
        status: '正常',
        mealTime: '晚餐后',
        dateTime: '03/30 19:00'
      },
      {
        value: 4.7,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '03/27 13:30'
      },
      {
        value: 5.5,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '03/24 09:00'
      },
      {
        value: 6.8,
        status: '偏高',
        mealTime: '晚餐后',
        dateTime: '03/21 19:45'
      },
      {
        value: 4.6,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '03/18 13:15'
      },
      {
        value: 5.0,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '03/15 09:20'
      },
      {
        value: 3.5,
        status: '偏低',
        mealTime: '晚餐前',
        dateTime: '03/12 18:30'
      },
      {
        value: 4.8,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '03/09 13:40'
      },
      {
        value: 5.3,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '03/06 09:10'
      },
      {
        value: 4.9,
        status: '正常',
        mealTime: '晚餐后',
        dateTime: '03/03 19:20'
      }
    ]
  },
  {
    monthTitle: '2025年2月',
    records: [
      {
        value: 5.1,
        status: '正常',
        mealTime: '晚餐后',
        dateTime: '02/28 19:00'
      },
      {
        value: 4.8,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '02/25 13:30'
      },
      {
        value: 5.4,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '02/22 09:00'
      },
      {
        value: 7.2,
        status: '偏高',
        mealTime: '晚餐后',
        dateTime: '02/19 19:45'
      },
      {
        value: 4.5,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '02/16 13:20'
      },
      {
        value: 5.0,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '02/13 09:15'
      },
      {
        value: 3.0,
        status: '偏低',
        mealTime: '晚餐前',
        dateTime: '02/10 18:25'
      },
      {
        value: 4.7,
        status: '正常',
        mealTime: '午餐后',
        dateTime: '02/07 13:35'
      },
      {
        value: 5.2,
        status: '正常',
        mealTime: '早餐后',
        dateTime: '02/04 09:05'
      },
      {
        value: 4.9,
        status: '正常',
        mealTime: '晚餐后',
        dateTime: '02/01 19:10'
      }
    ]
  }
];
