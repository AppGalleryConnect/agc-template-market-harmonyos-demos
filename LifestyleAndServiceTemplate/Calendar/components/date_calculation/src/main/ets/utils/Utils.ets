import { Lunar } from 'lunar';
import { weekdayMap } from '../constants/Index';
import dayjs from 'dayjs';
import { CALCULATION_TYPE, LuckyDays, LunarInfo } from '../model/model';

export function calculateDaysLater(day: string, later: number, forwardOrBack: CALCULATION_TYPE): LuckyDays {
  const today = new Date(day);
  const twoDaysLater = new Date(today);
  if (forwardOrBack === CALCULATION_TYPE.BACKWARD) {
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
    forwardOrBack,
    weekday: weekday,
  }
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

export function getLunarDay(date: Date): string {
  const lunar = Lunar.fromDate(dayjs(date).toDate());
  const lunarMonth = lunar.getMonthInChinese();
  const lunarDay = lunar.getDayInChinese()
  const lunarDate = `${lunarMonth}月${lunarDay}`;
  return lunarDate
}

export function getTodayYinLi(date: Date) {
  const lunar = Lunar.fromDate(date);
  const yearGanZhi = lunar.getYearInGanZhi(); // 获取天干地支年
  const shengXiao = lunar.getYearShengXiao(); // 获取生肖
  let monthGanZhi = lunar.getMonthInGanZhi(); // 获取月天干地支
  const dayGanZhi = lunar.getDayInGanZhi();
  return `${yearGanZhi}${shengXiao}年 ${monthGanZhi}月 ${dayGanZhi}日`;
}



const weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

export function gregorianToLunar(date: Date) {
  const lunar = Lunar.fromDate(date);
  const lunarInfo: LunarInfo = {
    year: lunar.getYearInGanZhi(),
    month: lunar.getMonthInChinese(),
    day: lunar.getDayInChinese(),
    weekday: weekday[date.getDay()],
  };
  return lunarInfo
}