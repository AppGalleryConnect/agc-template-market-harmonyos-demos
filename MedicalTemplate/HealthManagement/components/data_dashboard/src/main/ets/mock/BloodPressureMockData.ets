/**
 * 血压页面 Mock 数据
 */
import {
  TimeRange as BloodPressureTimeRange,
  BloodPressureRangeOption,
  MonthGroup as BloodPressureMonthGroup
} from '../types/BloodPressureTypes';

/**
 * 血压范围选项数据
 */
export const BLOOD_PRESSURE_RANGE_OPTIONS: Record<BloodPressureTimeRange, BloodPressureRangeOption[]> = {
  [BloodPressureTimeRange.WEEK]: [
    {
      label: '2025年04月24日 - 04月30日',
      period: '04月24日(周日)',
      currentSystolic: 128,
      currentDiastolic: 88,
      systolicValues: [130, 125, 128, 135, 120, 132, 128],
      diastolicValues: [95, 92, 98, 110, 100, 105, 88],
      labels: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
      statistics: { avgSystolic: 128, avgDiastolic: 98, avgPulse: 75 }
    },
    {
      label: '2024年02月20日 - 02月26日',
      period: '02月22日(周四)',
      currentSystolic: 125,
      currentDiastolic: 98,
      systolicValues: [132, 128, 125, 130, 127, 135, 120],
      diastolicValues: [98, 95, 98, 100, 96, 102, 94],
      labels: [],
      statistics: { avgSystolic: 129, avgDiastolic: 98, avgPulse: 73 }
    }
  ],
  [BloodPressureTimeRange.MONTH]: [
    {
      label: '2025年4月',
      period: '04月05日',
      currentSystolic: 128,
      currentDiastolic: 88,
      systolicValues: [125, 130, 128, 120, 165, 120, 128, 132, 128, 125, 130, 172, 132, 163, 126, 129, 127, 131, 124,
        133, 180, 128, 126, 134, 122, 129, 177, 131, 125, 130],
      diastolicValues: [95, 98, 88, 90, 110, 100, 95, 105, 88, 95, 98, 90, 100, 98, 92, 96, 89, 99, 91, 101, 93, 97, 94,
        102, 87, 96, 90, 99, 93, 98],
      labels: ['4/1', '4/2', '4/3', '4/4', '4/5', '4/6', '4/7', '4/8', '4/9', '4/10', '4/11', '4/12', '4/13', '4/14',
        '4/15', '4/16', '4/17', '4/18', '4/19', '4/20', '4/21', '4/22', '4/23', '4/24', '4/25', '4/26', '4/27', '4/28',
        '4/29', '4/30'],
      statistics: { avgSystolic: 128, avgDiastolic: 96, avgPulse: 75 }
    },
    {
      label: '2024年11月',
      period: '近一个月',
      currentSystolic: 122,
      currentDiastolic: 98,
      systolicValues: [128, 125, 130, 122, 127, 132, 120, 125, 128, 130, 124, 126, 129],
      diastolicValues: [96, 95, 98, 98, 97, 100, 94, 96, 98, 99, 95, 97, 98],
      labels: ['11/15', '', '11/20', '', '11/25', '', '12/1', '', '12/5', '', '12/10', '', '12/15'],
      statistics: { avgSystolic: 126, avgDiastolic: 97, avgPulse: 73 }
    }
  ],
  [BloodPressureTimeRange.THREE_MONTHS]: [
    {
      label: '2025年2月 - 04月',
      period: '3月平均值',
      currentSystolic: 128,
      currentDiastolic: 88,
      systolicValues: [
        128, 174, 130, 135, 165, 132, 128, 125, 180, 128, // 2月 10个
        135, 122, 128, 130, 125, 165, 128, 130, 125, 128, // 3月 10个
        125, 130, 128, 173, 120, 132, 128, 125, 130, 128// 4月 10个
      ],
      diastolicValues: [
        88, 95, 98, 110, 100, 105, 88, 95, 98, 88, // 2月 10个
        110, 92, 98, 100, 95, 105, 88, 98, 95, 88, // 3月 10个
        95, 98, 88, 110, 100, 105, 88, 95, 98, 88// 4月 10个
      ],
      labels: ['', '', '', '2月', '', '', '', '', '', '', '3月', '', '', '', '', '', '', '', '', '', '4月', '', '', '',
        '', '', '', '', '', ''],
      tooltipLabels: [],
      statistics: { avgSystolic: 128, avgDiastolic: 96, avgPulse: 75 }
    },
    {
      label: '2024年10月 - 12月',
      period: '11月平均值',
      currentSystolic: 123,
      currentDiastolic: 96,
      systolicValues: [126, 130, 118, 128],
      diastolicValues: [94, 98, 92, 96],
      labels: ['10月', '11月', '12月', ''],
      tooltipLabels: ['10月8日~10月15日', '11月8日~11月15日', '12月8日~12月15日', '12月16日~12月23日'],
      statistics: { avgSystolic: 125, avgDiastolic: 96, avgPulse: 72 }
    }
  ]
};

/**
 * 血压历史记录数据
 */
export const BLOOD_PRESSURE_HISTORY_MONTHS: BloodPressureMonthGroup[] = [
  {
    monthTitle: '2025年4月',
    records: [
      {
        systolic: 130,
        diastolic: 90,
        pulse: 76,
        status: '正常高值',
        dateTime: '04/28 19:00'
      },
      {
        systolic: 122,
        diastolic: 82,
        pulse: 72,
        status: '正常',
        dateTime: '04/24 18:30'
      },
      {
        systolic: 126,
        diastolic: 86,
        pulse: 74,
        status: '正常高值',
        dateTime: '04/20 20:15'
      },
      {
        systolic: 118,
        diastolic: 78,
        pulse: 70,
        status: '正常',
        dateTime: '04/16 19:45'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '04/12 18:20'
      },
      {
        systolic: 120,
        diastolic: 80,
        pulse: 71,
        status: '正常',
        dateTime: '04/08 19:30'
      },
      {
        systolic: 124,
        diastolic: 84,
        pulse: 73,
        status: '正常',
        dateTime: '04/04 18:50'
      }
    ]
  },
  {
    monthTitle: '2025年3月',
    records: [
      {
        systolic: 135,
        diastolic: 102,
        pulse: 78,
        status: '正常高值',
        dateTime: '03/30 19:00'
      },
      {
        systolic: 122,
        diastolic: 82,
        pulse: 72,
        status: '正常',
        dateTime: '03/27 18:30'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '03/24 20:15'
      },
      {
        systolic: 130,
        diastolic: 90,
        pulse: 76,
        status: '正常高值',
        dateTime: '03/21 19:45'
      },
      {
        systolic: 125,
        diastolic: 85,
        pulse: 74,
        status: '正常高值',
        dateTime: '03/18 18:20'
      },
      {
        systolic: 132,
        diastolic: 92,
        pulse: 77,
        status: '正常高值',
        dateTime: '03/15 19:30'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '03/12 18:50'
      },
      {
        systolic: 130,
        diastolic: 90,
        pulse: 76,
        status: '正常高值',
        dateTime: '03/09 20:00'
      },
      {
        systolic: 125,
        diastolic: 85,
        pulse: 74,
        status: '正常高值',
        dateTime: '03/06 19:15'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '03/03 18:40'
      }
    ]
  },
  {
    monthTitle: '2025年2月',
    records: [
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '02/28 19:00'
      },
      {
        systolic: 125,
        diastolic: 85,
        pulse: 73,
        status: '正常高值',
        dateTime: '02/25 18:30'
      },
      {
        systolic: 130,
        diastolic: 90,
        pulse: 76,
        status: '正常高值',
        dateTime: '02/22 20:15'
      },
      {
        systolic: 135,
        diastolic: 100,
        pulse: 78,
        status: '正常高值',
        dateTime: '02/19 19:45'
      },
      {
        systolic: 120,
        diastolic: 80,
        pulse: 71,
        status: '正常',
        dateTime: '02/16 18:20'
      },
      {
        systolic: 132,
        diastolic: 92,
        pulse: 77,
        status: '正常高值',
        dateTime: '02/13 19:30'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '02/10 18:50'
      },
      {
        systolic: 125,
        diastolic: 85,
        pulse: 74,
        status: '正常高值',
        dateTime: '02/07 20:00'
      },
      {
        systolic: 130,
        diastolic: 90,
        pulse: 76,
        status: '正常高值',
        dateTime: '02/04 19:15'
      },
      {
        systolic: 127,
        diastolic: 86,
        pulse: 71,
        status: '正常高值',
        dateTime: '02/03 19:45'
      },
      {
        systolic: 128,
        diastolic: 88,
        pulse: 75,
        status: '正常高值',
        dateTime: '02/01 18:40'
      }
    ]
  }
];

