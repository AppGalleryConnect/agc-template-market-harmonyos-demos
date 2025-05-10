import dayjs from 'dayjs';
import { Lunar } from 'lunar';
import { LuckyDays, SolarToLunar } from '../models/CommonModel';

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
  { name: '国庆节', month: 9, day: 1 },
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

function getDaysDiff(start: Date, end: Date): number {
  return Math.ceil((end.getTime() - start.getTime()) / (1000 * 3600 * 24));
}

export function calculateNextEvents(date: string): EventInfo[] {
  const today = new Date(date);
  const endDate = new Date(today);
  endDate.setMonth(endDate.getMonth() + 2);
  const events: EventInfo[] = [];
  const currentYear = today.getFullYear();

  FESTIVALS.forEach((item) => {
    for (let year = currentYear; year <= currentYear + 1; year++) {
      const date = new Date(year, item.month, item.day);
      if (date >= today && date <= endDate) {
        events.push({
          name: item.name,
          date: date.toISOString().split('T')[0],
          daysUntil: getDaysDiff(today, date),
        });
      }
    }
  });

  for (let year = currentYear; year <= currentYear + 1; year++) {
    TERM_NAMES.forEach((name, index) => {
      const date = getSolarTerm(year, index);
      if (date >= today && date <= endDate) {
        events.push({
          name,
          date: date.toISOString().split('T')[0],
          daysUntil: getDaysDiff(today, date),
        });
      }
    });
  }

  return events
    .filter((v, i, a) => a.findIndex(t => t.date === v.date && t.name === v.name) === i)
    .sort((a, b) => a.daysUntil - b.daysUntil);
}


export function getLuckyMarriageDaysInTwoMonths(title: string, start: Date, end?: Date) {
  let twoMonthsLater = new Date(start);
  if (end) {
    twoMonthsLater = new Date(end)
  } else {
    twoMonthsLater.setMonth(twoMonthsLater.getMonth() + 2);
  }
  const luckyDays: LuckyDays[] = [];
  let currentDate = new Date(start);

  while (currentDate <= twoMonthsLater) {
    const lunar = Lunar.fromDate(currentDate);
    if (lunar.getDayYi().includes(title)) {
      const timeDiff = currentDate.getTime() - start.getTime();
      const daysFromNow = Math.ceil(timeDiff / (1000 * 3600 * 24));
      luckyDays.push({
        solarDate: new Date(currentDate),
        lunarDate: lunar.toString(),
        ganZhiYear: lunar.getYearInGanZhi(),
        ganZhiMonth: lunar.getMonthInGanZhi(),
        ganZhiDay: lunar.getDayInGanZhi(),
        daysFromNow,
        weekday: weekdayMap[currentDate.getDay()],
      });
    }
    currentDate.setDate(currentDate.getDate() + 1);
  }

  return luckyDays;
}

export function getCurEndDate(currentDate: string | Date) {
  const dateObj = new Date(currentDate);
  const twoMonthsLater = new Date(dateObj);
  twoMonthsLater.setMonth(dateObj.getMonth() + 2);
  if (dateObj.getDate() > twoMonthsLater.getDate()) {
    twoMonthsLater.setDate(0);
  }
  const lunar = Lunar.fromDate(twoMonthsLater);
  const lunarDate = lunar.toString();
  const weekday = weekdayMap[twoMonthsLater.getDay()];
  return `${dayjs(twoMonthsLater).format('YYYY.MM.DD')} ${weekday} ${lunarDate}`;
}

export function getCurEndAllDate(currentDate: string | Date) {
  const dateObj = new Date(currentDate);
  const twoMonthsLater = new Date(dateObj);
  twoMonthsLater.setMonth(dateObj.getMonth() + 2);
  if (dateObj.getDate() > twoMonthsLater.getDate()) {
    twoMonthsLater.setDate(0);
  }
  return `${dayjs(twoMonthsLater).format('YYYY-MM-DD')}`;
}

export function calculateDaysBetweenDates(date1: string, date2: string): number {
  const d1 = new Date(date1);
  const d2 = new Date(date2);
  const timestamp1 = d1.getTime();
  const timestamp2 = d2.getTime();
  const differenceInMilliseconds = Math.abs(timestamp2 - timestamp1);
  const oneDayInMilliseconds = 24 * 60 * 60 * 1000;
  const differenceInDays = Math.floor(differenceInMilliseconds / oneDayInMilliseconds);
  return differenceInDays;
}

export function calculateDaysLater(day: string, later: number, forwardOrBack: boolean): LuckyDays {
  const today = new Date(day);
  const twoDaysLater = new Date(today);
  if (forwardOrBack) {
    twoDaysLater.setDate(today.getDate() + later);
  } else {
    twoDaysLater.setDate(today.getDate() - later);
  }
  const lunar = Lunar.fromDate(twoDaysLater);
  const ganZhiYear = lunar.getYearInGanZhi()
  const ganZhiMonth = lunar.getMonthInGanZhi()
  const ganZhiDay = lunar.getDayInGanZhi()

  const weekday = weekdayMap[twoDaysLater.getDay()];
  // 计算距离今天的天数
  const daysFromNow = later;
  return {
    solarDate: twoDaysLater.toLocaleDateString(),
    lunarDate: lunar.toString(),
    ganZhiYear: ganZhiYear,
    ganZhiMonth: ganZhiMonth,
    ganZhiDay: ganZhiDay,
    daysFromNow,
    weekday: weekday,
  }
}
