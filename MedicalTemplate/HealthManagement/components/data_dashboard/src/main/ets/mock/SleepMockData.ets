/**
 * 睡眠页面 Mock 数据
 */
import {
  TimeRange as SleepTimeRange,
  SleepRangeOption,
  MonthGroup as SleepMonthGroup
} from '../types/SleepTypes';

/**
 * 睡眠范围选项数据
 */
export const SLEEP_RANGE_OPTIONS: Record<SleepTimeRange, SleepRangeOption[]> = {
  [SleepTimeRange.WEEK]: [
    {
      label: '2025年04月24日 - 04月30日',
      currentDate: '04月24日(周日)',
      totalHour: 8,
      totalMinute: 30,
      sleepData: [
        [1.5, 4.0, 1.2, 0.8], // 周日：7.5小时
        [1.2, 3.5, 0.9, 0.6], // 周一：6.2小时
        [1.8, 4.5, 1.3, 0.9], // 周二：8.5小时
        [1.0, 3.0, 0.8, 0.5], // 周三：5.3小时
        [1.6, 4.2, 1.1, 0.8], // 周四：7.7小时
        [1.3, 3.8, 1.0, 0.7], // 周五：6.8小时
        [1.9, 4.8, 1.4, 1.0]// 周六：9.1小时
      ],
      labels: ['04月24日', '04月25日', '04月26日', '04月27日', '04月28日', '04月29日', '04月30日'],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 17,
        avgLightSleep: 3,
        avgLightSleepMinute: 35,
        avgREM: 30,
        avgAwake: 20
      }
    },
    {
      label: '2025年02月17日 - 02月23日',
      currentDate: '02月20日(周四)',
      totalHour: 7,
      totalMinute: 45,
      sleepData: [
        [0.9, 3.0, 0.8, 0.6], // 周日：02月17日
        [1.1, 3.2, 0.9, 0.7], // 周一：02月18日
        [0.8, 2.6, 0.7, 0.5], // 周二：02月19日
        [1.0, 3.1, 0.8, 0.6], // 周三：02月20日
        [1.2, 3.4, 0.9, 0.7], // 周四：02月21日
        [0.9, 2.9, 0.8, 0.6], // 周五：02月22日
        [1.0, 3.0, 0.8, 0.5]// 周六：02月23日
      ],
      labels: ['02月17日', '02月18日', '02月19日', '02月20日', '02月21日', '02月22日', '02月23日'],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 10,
        avgLightSleep: 2,
        avgLightSleepMinute: 50,
        avgREM: 28,
        avgAwake: 22
      }
    },
    {
      label: '2025年02月10日 - 02月16日',
      currentDate: '02月13日(周五)',
      totalHour: 8,
      totalMinute: 15,
      sleepData: [
        [1.1, 3.3, 0.9, 0.7],
        [0.9, 2.7, 0.8, 0.5],
        [1.2, 3.5, 0.9, 0.6],
        [1.0, 3.0, 0.8, 0.6],
        [0.9, 2.8, 0.7, 0.5],
        [1.1, 3.2, 0.9, 0.7],
        [1.0, 3.1, 0.8, 0.6]
      ],
      labels: [],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 30,
        avgLightSleep: 2,
        avgLightSleepMinute: 30,
        avgREM: 32,
        avgAwake: 18
      }
    },
    {
      label: '2025年02月03日 - 02月09日',
      currentDate: '02月06日(周四)',
      totalHour: 8,
      totalMinute: 0,
      sleepData: [
        [1.0, 3.1, 0.8, 0.6],
        [1.2, 3.4, 0.9, 0.7],
        [0.9, 2.9, 0.8, 0.6],
        [1.1, 3.2, 0.9, 0.7],
        [0.8, 2.6, 0.7, 0.5],
        [1.0, 3.0, 0.8, 0.6],
        [1.1, 3.3, 0.9, 0.7]
      ],
      labels: [],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 15,
        avgLightSleep: 2,
        avgLightSleepMinute: 45,
        avgREM: 29,
        avgAwake: 21
      }
    },
    {
      label: '2025年03月27日 - 04月02日',
      currentDate: '03月30日(周日)',
      totalHour: 7,
      totalMinute: 50,
      sleepData: [
        [0.9, 2.8, 0.7, 0.5],
        [1.1, 3.2, 0.9, 0.7],
        [1.0, 3.0, 0.8, 0.6],
        [1.2, 3.5, 0.9, 0.6],
        [0.9, 2.7, 0.8, 0.5],
        [1.0, 3.1, 0.8, 0.6],
        [1.1, 3.3, 0.9, 0.7]
      ],
      labels: [],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 5,
        avgLightSleep: 2,
        avgLightSleepMinute: 55,
        avgREM: 27,
        avgAwake: 23
      }
    }
  ],
  [SleepTimeRange.MONTH]: [
    {
      label: '2025年4月',
      currentDate: '04月19日',
      totalHour: 8,
      totalMinute: 30,
      sleepData: [
        [1.2, 3.5, 1.0, 0.6], [1.5, 3.8, 1.2, 0.7], [1.3, 3.6, 1.1, 0.6], // 4/2-4/4 连续3天
        [1.4, 3.7, 1.2, 0.7], [1.6, 3.9, 1.3, 0.8], // 4/7-4/8 连续2天
        [1.3, 3.6, 1.1, 0.7], // 4/12 单独1天
        [1.5, 3.8, 1.2, 0.7], [1.2, 3.5, 1.0, 0.6], [1.4, 3.7, 1.1, 0.7], [1.1, 3.4, 1.0, 0.6], // 4/15-4/18 连续4天
        [1.6, 3.9, 1.3, 0.8], [1.3, 3.6, 1.1, 0.7], [1.5, 3.8, 1.2, 0.7], // 4/20-4/22 连续3天
        [1.2, 3.5, 1.0, 0.6], [1.4, 3.7, 1.1, 0.7], // 4/25-4/26 连续2天
        [1.6, 3.9, 1.3, 0.8], [1.3, 3.6, 1.1, 0.7]// 4/29-4/30 连续2天
      ],
      labels: ['', '4/2', '4/3', '4/4', '', '', '4/7', '4/8', '', '', '', '4/12', '', '', '4/15', '4/16', '4/17',
        '4/18', '', '4/20', '4/21', '4/22', '', '', '4/25', '4/26', '', '', '4/29', '4/30'],
      groupSizes: [],
      statistics: {
        avgDeepSleep: 3,
        avgDeepSleepMinute: 45,
        avgLightSleep: 2,
        avgLightSleepMinute: 46,
        avgREM: 35,
        avgAwake: 25
      }
    },
    {
      label: '2025年3月',
      currentDate: '03月15日',
      totalHour: 0,
      totalMinute: 0,
      sleepData: [
        [1.1, 3.3, 0.9, 0.7], [0.9, 2.9, 0.8, 0.6], [1.2, 3.4, 0.8, 0.7], [1.0, 3.1, 0.8, 0.6], [1.1, 3.2, 0.9, 0.7],
        [0.9, 2.7, 0.7, 0.5], [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.6], [1.1, 3.1, 0.9, 0.7]
      ],
      labels: ['3/2', '', '3/10', '', '3/17', '', '3/24', '', '3/31'],
      groupSizes: [2, 1, 2, 2, 2],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 15,
        avgLightSleep: 2,
        avgLightSleepMinute: 45,
        avgREM: 31,
        avgAwake: 19
      }
    },
    {
      label: '2025年2月',
      currentDate: '02月12日',
      totalHour: 0,
      totalMinute: 0,
      sleepData: [
        [1.0, 3.0, 0.8, 0.6], [1.2, 3.4, 0.9, 0.7], [0.9, 2.8, 0.7, 0.5], [1.1, 3.2, 0.9, 0.7], [1.0, 3.1, 0.8, 0.6],
        [1.2, 3.5, 0.9, 0.6], [0.9, 2.7, 0.8, 0.5], [1.1, 3.3, 0.9, 0.7], [1.0, 3.0, 0.8, 0.6]
      ],
      labels: ['2/1', '', '2/9', '', '2/16', '', '2/23', '', '2/28'],
      groupSizes: [2, 1, 2, 2, 2],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 10,
        avgLightSleep: 2,
        avgLightSleepMinute: 50,
        avgREM: 29,
        avgAwake: 21
      }
    },
    {
      label: '2024年09月',
      currentDate: '09月18日',
      totalHour: 0,
      totalMinute: 0,
      sleepData: [
        [1.1, 3.2, 0.9, 0.7], [0.9, 2.9, 0.8, 0.6], [1.2, 3.4, 0.8, 0.7], [1.0, 3.1, 0.8, 0.6], [1.1, 3.3, 0.9, 0.7],
        [0.9, 2.8, 0.7, 0.5], [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.6], [1.1, 3.1, 0.9, 0.7]
      ],
      labels: ['9/4', '', '9/8', '', '9/16', '', '9/20', '', '10/2'],
      groupSizes: [2, 1, 2, 2, 2],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 25,
        avgLightSleep: 2,
        avgLightSleepMinute: 35,
        avgREM: 32,
        avgAwake: 18
      }
    },
    {
      label: '2024年08月',
      currentDate: '08月22日',
      totalHour: 0,
      totalMinute: 0,
      sleepData: [
        [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.6], [0.9, 2.8, 0.7, 0.5], [1.1, 3.2, 0.9, 0.7], [1.0, 3.1, 0.8, 0.6],
        [1.2, 3.4, 0.8, 0.7], [0.9, 2.7, 0.8, 0.5], [1.1, 3.3, 0.9, 0.7], [1.0, 3.0, 0.8, 0.6]
      ],
      labels: ['8/4', '', '8/8', '', '8/16', '', '8/20', '', '9/2'],
      groupSizes: [2, 1, 2, 2, 2],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 30,
        avgLightSleep: 2,
        avgLightSleepMinute: 30,
        avgREM: 33,
        avgAwake: 17
      }
    }
  ],
  [SleepTimeRange.THREE_MONTHS]: [
    {
      label: '2025年2月 - 04月',
      currentDate: '总时长',
      totalHour: 230,
      totalMinute: 0,
      sleepData: [
        [1.8, 4.5, 1.3, 0.9], [1.5, 4.0, 1.1, 0.7], [1.2, 3.5, 0.9, 0.6], [0.9, 2.8, 0.7, 0.5], // 2月：从高到低
        [1.0, 3.0, 0.8, 0.5], [1.3, 3.7, 1.0, 0.6], [1.6, 4.2, 1.2, 0.8], [1.9, 4.8, 1.4, 1.0], // 3月：从低到高
        [1.7, 4.3, 1.2, 0.8], [1.4, 3.9, 1.0, 0.7], [1.1, 3.3, 0.9, 0.6], [0.8, 2.6, 0.7, 0.4]// 4月：从高到低
      ],
      labels: ['2月', '3月', '4月'],
      groupSizes: [4, 4, 4],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 30,
        avgLightSleep: 2,
        avgLightSleepMinute: 50,
        avgREM: 25,
        avgAwake: 15
      }
    },
    {
      label: '2024年1月 - 03月',
      currentDate: '总时长',
      totalHour: 225,
      totalMinute: 0,
      sleepData: [
        [1.1, 3.2, 0.9, 0.7], [0.9, 2.9, 0.8, 0.6], [1.2, 3.4, 0.8, 0.7], [1.0, 3.1, 0.8, 0.6],
        [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.6], [0.9, 2.8, 0.7, 0.5], [1.1, 3.3, 0.9, 0.7],
        [1.2, 3.4, 0.8, 0.6], [1.0, 3.1, 0.9, 0.7], [1.1, 3.2, 0.8, 0.6], [0.9, 2.7, 0.7, 0.5]
      ],
      labels: ['1月', '2月', '3月'],
      groupSizes: [4, 4, 4],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 15,
        avgLightSleep: 2,
        avgLightSleepMinute: 45,
        avgREM: 31,
        avgAwake: 19
      }
    },
    {
      label: '2023年12月 - 2024年02月',
      currentDate: '总时长',
      totalHour: 235,
      totalMinute: 0,
      sleepData: [
        [1.0, 3.0, 0.8, 0.6], [1.2, 3.4, 0.9, 0.7], [0.9, 2.8, 0.7, 0.5], [1.1, 3.2, 0.9, 0.7],
        [1.2, 3.5, 0.9, 0.6], [1.0, 3.1, 0.8, 0.6], [0.9, 2.7, 0.8, 0.5], [1.1, 3.3, 0.9, 0.7],
        [1.2, 3.4, 0.8, 0.6], [1.0, 3.0, 0.9, 0.7], [1.1, 3.2, 0.8, 0.6], [0.9, 2.9, 0.7, 0.5]
      ],
      labels: ['12月', '1月', '2月'],
      groupSizes: [4, 4, 4],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 25,
        avgLightSleep: 2,
        avgLightSleepMinute: 35,
        avgREM: 32,
        avgAwake: 18
      }
    },
    {
      label: '2023年11月 - 2024年01月',
      currentDate: '总时长',
      totalHour: 228,
      totalMinute: 0,
      sleepData: [
        [1.1, 3.2, 0.9, 0.7], [0.9, 2.9, 0.8, 0.6], [1.2, 3.4, 0.8, 0.7], [1.0, 3.1, 0.8, 0.6],
        [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.6], [0.9, 2.8, 0.7, 0.5], [1.1, 3.3, 0.9, 0.7],
        [1.2, 3.4, 0.8, 0.6], [1.0, 3.1, 0.9, 0.7], [1.1, 3.2, 0.8, 0.6], [0.9, 2.7, 0.7, 0.5]
      ],
      labels: ['11月', '12月', '1月'],
      groupSizes: [4, 4, 4],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 10,
        avgLightSleep: 2,
        avgLightSleepMinute: 50,
        avgREM: 29,
        avgAwake: 21
      }
    },
    {
      label: '2023年10月 - 2023年12月',
      currentDate: '总时长',
      totalHour: 232,
      totalMinute: 0,
      sleepData: [
        [1.2, 3.5, 0.9, 0.6], [1.0, 3.0, 0.8, 0.5], [1.1, 3.3, 0.9, 0.7], [0.9, 2.8, 0.7, 0.5],
        [1.3, 3.6, 0.9, 0.6], [1.0, 3.1, 0.8, 0.6], [0.9, 2.7, 0.7, 0.5], [1.1, 3.2, 0.8, 0.6],
        [1.2, 3.4, 0.8, 0.6], [1.0, 3.0, 0.9, 0.7], [1.1, 3.3, 0.8, 0.6], [0.9, 2.9, 0.7, 0.5]
      ],
      labels: ['10月', '11月', '12月'],
      groupSizes: [4, 4, 4],
      statistics: {
        avgDeepSleep: 4,
        avgDeepSleepMinute: 30,
        avgLightSleep: 2,
        avgLightSleepMinute: 30,
        avgREM: 33,
        avgAwake: 17
      }
    }
  ]
};

/**
 * 睡眠历史记录数据
 */
export const SLEEP_HISTORY_MONTHS: SleepMonthGroup[] = [
  {
    monthTitle: '2025年4月',
    records: [
      { duration: '8小时30分钟', dateTime: '4月30日' },
      { duration: '7小时45分钟', dateTime: '4月29日' },
      { duration: '8小时15分钟', dateTime: '4月28日' },
      { duration: '7小时50分钟', dateTime: '4月27日' },
      { duration: '8小时20分钟', dateTime: '4月26日' },
      { duration: '7小时40分钟', dateTime: '4月25日' },
      { duration: '8小时10分钟', dateTime: '4月24日' },
      { duration: '7小时55分钟', dateTime: '4月23日' },
      { duration: '8小时25分钟', dateTime: '4月22日' },
      { duration: '7小时35分钟', dateTime: '4月21日' },
      { duration: '8小时05分钟', dateTime: '4月20日' },
      { duration: '7小时50分钟', dateTime: '4月19日' },
      { duration: '8小时15分钟', dateTime: '4月18日' },
      { duration: '7小时45分钟', dateTime: '4月17日' },
      { duration: '8小时30分钟', dateTime: '4月16日' },
      { duration: '7小时55分钟', dateTime: '4月15日' },
      { duration: '8小时10分钟', dateTime: '4月14日' },
      { duration: '7小时40分钟', dateTime: '4月13日' },
      { duration: '8小时20分钟', dateTime: '4月12日' },
      { duration: '7小时50分钟', dateTime: '4月11日' },
      { duration: '8小时05分钟', dateTime: '4月10日' },
      { duration: '7小时45分钟', dateTime: '4月09日' },
      { duration: '8小时25分钟', dateTime: '4月08日' },
      { duration: '7小时35分钟', dateTime: '4月07日' },
      { duration: '8小时15分钟', dateTime: '4月06日' },
      { duration: '7小时55分钟', dateTime: '4月05日' },
      { duration: '8小时10分钟', dateTime: '4月04日' },
      { duration: '7小时40分钟', dateTime: '4月03日' },
      { duration: '8小时30分钟', dateTime: '4月02日' },
      { duration: '7小时50分钟', dateTime: '4月01日' }
    ]
  },
  {
    monthTitle: '2025年3月',
    records: [
      { duration: '8小时25分钟', dateTime: '3月30日' },
      { duration: '7小时50分钟', dateTime: '3月27日' },
      { duration: '8小时15分钟', dateTime: '3月24日' },
      { duration: '7小时45分钟', dateTime: '3月21日' },
      { duration: '8小时30分钟', dateTime: '3月18日' },
      { duration: '7小时55分钟', dateTime: '3月15日' },
      { duration: '8小时10分钟', dateTime: '3月12日' },
      { duration: '7小时40分钟', dateTime: '3月09日' },
      { duration: '8小时20分钟', dateTime: '3月06日' },
      { duration: '7小时50分钟', dateTime: '3月03日' }
    ]
  },
  {
    monthTitle: '2025年2月',
    records: [
      { duration: '8小时15分钟', dateTime: '2月28日' },
      { duration: '7小时45分钟', dateTime: '2月25日' },
      { duration: '8小时25分钟', dateTime: '2月22日' },
      { duration: '7小时50分钟', dateTime: '2月19日' },
      { duration: '8小时10分钟', dateTime: '2月16日' },
      { duration: '7小时55分钟', dateTime: '2月13日' },
      { duration: '8小时20分钟', dateTime: '2月10日' },
      { duration: '7小时40分钟', dateTime: '2月07日' },
      { duration: '8小时30分钟', dateTime: '2月04日' },
      { duration: '7小时50分钟', dateTime: '2月01日' }
    ]
  }
];


