/**
 * 心率页面 Mock 数据
 */
import {
  TimeRange as HeartRateTimeRange,
  HeartRateRangeOption,
  MonthGroup as HeartRateMonthGroup,
  HeartRateRecord
} from '../types/HeartRateTypes';

/**
 * 心率范围选项数据
 */
export const HEART_RATE_RANGE_OPTIONS: Record<HeartRateTimeRange, HeartRateRangeOption[]> = {
  [HeartRateTimeRange.WEEK]: [
    {
      label: '2025年04月24日 - 04月30日',
      period: '',
      currentRange: '79-112',
      ranges: [[45, 85], [28, 98], [40, 88], [25, 90], [42, 95], [32, 125], [30, 80]],
      labels: [],
      statistics: {
        avgHigh: 96,
        avgLow: 68,
        restingHigh: 76,
        restingLow: 82
      }
    }
  ],
  [HeartRateTimeRange.MONTH]: [
    {
      label: '2025年4月',
      period: '',
      currentRange: '79-112',
      ranges: [
        [45, 100], [35, 70], [40, 90], [38, 75], [48, 85], [50, 100], [45, 95], [42, 95], [35, 75], [52, 105], // 0-9
        [46, 98], [41, 88], [44, 92], [39, 78], [47, 96], [43, 85], [36, 72], [49, 101], [44, 89], [40, 82], // 10-19
        [46, 94], [42, 87], [38, 76], [51, 103], [45, 91], [41, 84], [47, 93], [43, 86], [39, 79], [48, 97]// 20-29
      ],
      labels: ['4/1', '', '', '', '4/5', '', '', '', '', '4/10', '', '', '', '', '4/15', '', '', '', '', '4/20', '', '',
        '', '', '4/25', '', '', '', '', '4/30'],
      groupSizes: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      statistics: {
        avgHigh: 96,
        avgLow: 68,
        restingHigh: 76,
        restingLow: 82
      }
    }
  ],
  [HeartRateTimeRange.THREE_MONTHS]: [
    {
      label: '2025年2月 - 04月',
      period: '',
      currentRange: '79-112',
      ranges: [
        [35, 100], [40, 110], [30, 95], [45, 120],
        [28, 98], [38, 115], [25, 90], [32, 105],
        [30, 110], [36, 118], [34, 108], [40, 120]
      ],
      labels: ['2月', '3月', '4月'],
      tooltipLabels: [
        '2月1日～2月7日', '2月8日～2月14日', '2月15日～2月21日', '2月22日～2月29日',
        '3月1日～3月7日', '3月8日～3月14日', '3月15日～3月21日', '3月22日～3月31日',
        '4月1日～4月7日', '4月8日～4月14日', '4月15日～4月21日', '4月22日～4月30日'
      ],
      groupSizes: [4, 4, 4],
      statistics: {
        avgHigh: 96,
        avgLow: 68,
        restingHigh: 76,
        restingLow: 82
      }
    }
  ]
};

/**
 * 心率历史记录数据
 */
export const HEART_RATE_HISTORY_MONTHS: HeartRateMonthGroup[] = [
  {
    monthTitle: '2025年4月',
    records: [
      { range: '56 ~ 121次/分钟', dateTime: '4月30日' },
      { range: '60 ~ 115次/分钟', dateTime: '4月29日' },
      { range: '58 ~ 118次/分钟', dateTime: '4月28日' },
      { range: '62 ~ 120次/分钟', dateTime: '4月27日' },
      { range: '55 ~ 112次/分钟', dateTime: '4月26日' },
      { range: '59 ~ 116次/分钟', dateTime: '4月25日' },
      { range: '61 ~ 119次/分钟', dateTime: '4月24日' },
      { range: '57 ~ 114次/分钟', dateTime: '4月23日' },
      { range: '63 ~ 122次/分钟', dateTime: '4月22日' },
      { range: '58 ~ 117次/分钟', dateTime: '4月21日' },
      { range: '60 ~ 113次/分钟', dateTime: '4月20日' },
      { range: '56 ~ 118次/分钟', dateTime: '4月19日' },
      { range: '59 ~ 115次/分钟', dateTime: '4月18日' },
      { range: '61 ~ 120次/分钟', dateTime: '4月17日' },
      { range: '57 ~ 116次/分钟', dateTime: '4月16日' },
      { range: '62 ~ 119次/分钟', dateTime: '4月15日' },
      { range: '58 ~ 114次/分钟', dateTime: '4月14日' },
      { range: '60 ~ 121次/分钟', dateTime: '4月13日' },
      { range: '55 ~ 117次/分钟', dateTime: '4月12日' },
      { range: '59 ~ 118次/分钟', dateTime: '4月11日' },
      { range: '61 ~ 115次/分钟', dateTime: '4月10日' },
      { range: '57 ~ 120次/分钟', dateTime: '4月09日' },
      { range: '63 ~ 116次/分钟', dateTime: '4月08日' },
      { range: '58 ~ 119次/分钟', dateTime: '4月07日' },
      { range: '60 ~ 114次/分钟', dateTime: '4月06日' },
      { range: '56 ~ 122次/分钟', dateTime: '4月05日' },
      { range: '59 ~ 117次/分钟', dateTime: '4月04日' },
      { range: '61 ~ 113次/分钟', dateTime: '4月03日' },
      { range: '57 ~ 118次/分钟', dateTime: '4月02日' },
      { range: '62 ~ 115次/分钟', dateTime: '4月01日' }
    ]
  },
  {
    monthTitle: '2025年3月',
    records: [
      { range: '58 ~ 117次/分钟', dateTime: '3月30日' },
      { range: '60 ~ 120次/分钟', dateTime: '3月27日' },
      { range: '56 ~ 113次/分钟', dateTime: '3月24日' },
      { range: '62 ~ 122次/分钟', dateTime: '3月21日' },
      { range: '59 ~ 118次/分钟', dateTime: '3月18日' },
      { range: '57 ~ 115次/分钟', dateTime: '3月15日' },
      { range: '61 ~ 119次/分钟', dateTime: '3月12日' },
      { range: '58 ~ 116次/分钟', dateTime: '3月9日' },
      { range: '60 ~ 121次/分钟', dateTime: '3月6日' },
      { range: '56 ~ 114次/分钟', dateTime: '3月3日' }
    ]
  },
  {
    monthTitle: '2025年2月',
    records: [
      { range: '59 ~ 118次/分钟', dateTime: '2月28日' },
      { range: '57 ~ 115次/分钟', dateTime: '2月25日' },
      { range: '61 ~ 120次/分钟', dateTime: '2月22日' },
      { range: '58 ~ 117次/分钟', dateTime: '2月19日' },
      { range: '60 ~ 119次/分钟', dateTime: '2月16日' },
      { range: '56 ~ 116次/分钟', dateTime: '2月13日' },
      { range: '62 ~ 121次/分钟', dateTime: '2月10日' },
      { range: '59 ~ 118次/分钟', dateTime: '2月7日' },
      { range: '57 ~ 114次/分钟', dateTime: '2月4日' },
      { range: '60 ~ 122次/分钟', dateTime: '2月1日' }
    ]
  }
];

/**
 * 心率详情记录数据
 */
export const HEART_RATE_DETAIL_RECORDS: HeartRateRecord[] = [
  { value: '92次/分钟', time: '18:27' },
  { value: '121次/分钟', time: '18:22' },
  { value: '63次/分钟', time: '09:00' },
  { value: '100次/分钟', time: '08:34' },
  { value: '99次/分钟', time: '08:12' },
  { value: '00次/分钟', time: '07:34' }
];

