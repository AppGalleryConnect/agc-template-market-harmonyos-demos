import { getDaysDiff } from 'base_apis';

interface EventInfo {
  name: string;
  date: string;
  daysUntil: number;
}

interface FestivalsInfo {
  name: string;
  month: number;
  day: number;
}

export const weekdayMap = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

const FESTIVALS: FestivalsInfo[] = [
  { name: '元旦', month: 0, day: 1 },
  { name: '情人节', month: 1, day: 14 },
  { name: '劳动节', month: 4, day: 1 },
  { name: '端午节', month: 4, day: 31 },
  { name: '国庆节', month: 9, day: 1 },
  { name: '中秋节', month: 9, day: 6 },
  { name: '圣诞节', month: 11, day: 25 },
];

const TERM_NAMES = [
  '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
  '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
  '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
  '寒露', '霜降', '立冬', '小雪', '大雪', '冬至',
];
const TERM_PARAMS = [
  0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551,
  218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447,
  419210, 440795, 462224, 483532, 504758,
];


function getSolarTerm(year: number, termIndex: number): Date {
  const ms = (year - 1900) * 31556925974.7 + TERM_PARAMS[termIndex] * 60000;
  return new Date(Date.UTC(1900, 0, 6, 2, 5) + ms);
}

export function calculateNextEvents(date: string): EventInfo[] {
  const dateFormat = `${date} 00:00:00`
  // 对齐输入的日期到本地午夜
  const today = new Date(date);
  const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());

  // 计算两个月后的截止日期（对齐到午夜）
  const endDate = new Date(todayStart);
  endDate.setMonth(endDate.getMonth() + 2);
  const endDateStart = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());

  const events: EventInfo[] = [];
  const currentYear = todayStart.getFullYear();

  // 处理固定节日
  FESTIVALS.forEach((item) => {
    for (let year = currentYear; year <= currentYear + 1; year++) {
      // 直接创建无时间成分的日期对象
      const eventDate = new Date(year, item.month, item.day);

      // 精确比较对齐后的日期
      if (eventDate >= todayStart && eventDate <= endDateStart) {
        events.push({
          name: item.name,
          date: formatLocalDate(eventDate),
          daysUntil: getDaysDiff(todayStart, eventDate),
        });
      }
    }
  });

  // 处理节气
  for (let year = currentYear; year <= currentYear + 1; year++) {
    TERM_NAMES.forEach((name, index) => {
      const termDate = getSolarTerm(year, index);
      // 将UTC时间转换为本地日期
      const termLocalDate = new Date(
        termDate.getUTCFullYear(),
        termDate.getUTCMonth(),
        termDate.getUTCDate(),
      );

      if (termLocalDate >= todayStart && termLocalDate <= endDateStart) {
        events.push({
          name,
          date: formatLocalDate(termLocalDate),
          daysUntil: getDaysDiff(todayStart, termLocalDate),
        });
      }
    });
  }

  return events
    .filter((v, i, a) => a.findIndex(t => t.date === v.date && t.name === v.name) === i)
    .sort((a, b) => a.daysUntil - b.daysUntil);
}

function formatLocalDate(date: Date): string {
  return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
    .toString()
    .padStart(2, '0')}`;
}
