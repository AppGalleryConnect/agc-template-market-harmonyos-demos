import { Lunar } from 'lunar';
import dayjs from 'dayjs';
import { HolidayInfo, SolarInfo } from '../model/model';

export function getPublicFestival(date:Date) {
  const startDate: Date = date;
  const endDate: Date = new Date(date.getFullYear(), 11, 31);

  const holidays: HolidayInfo[] = [];

  let currentDate: Date = new Date(startDate);
  while (currentDate <= endDate) {
    const lunar = Lunar.fromDate(currentDate);
    const holiday = lunar.getFestivals();
    const otherHoliday = lunar.getOtherFestivals();
      // 计算距离今天的天数
      const diffTime: number = Math.abs(date.getTime() - currentDate.getTime());
      const diffDays: number = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      if(holiday.length) {
        holidays.push({
          month:`${currentDate.getMonth() + 1}月`,
          day:`${currentDate.getDate()}`,
          solarDate: `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月${currentDate.getDate()}日`,
          lunarDate: `${lunar.getYearInChinese()} ${lunar.getMonthInChinese()}${lunar.getDayInChinese()}`,
          holidayName: holiday,
          daysUntil: diffDays,
        });
      }
      if(otherHoliday.length) {
        holidays.push({
          month:`${currentDate.getMonth() + 1}月`,
          day:`${currentDate.getDate()}`,
          solarDate: `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月${currentDate.getDate()}日`,
          lunarDate: `${lunar.getYearInChinese()} ${lunar.getMonthInChinese()}${lunar.getDayInChinese()}`,
          holidayName: otherHoliday,
          daysUntil: diffDays,
        });
      }
    // 移动到下一天
    currentDate.setDate(currentDate.getDate() + 1);
  }
  return holidays
}



export function getSolarInfo(date: Date) {
  const year = dayjs(date).format('YYYY')
  const startDate: Date = new Date(Number(year), 0, 1);
  const endDate: Date = new Date(date.getFullYear(), 11, 31);
  const solarTerms: SolarInfo[] = [];

  let currentDate: Date = new Date(startDate);
  while (currentDate <= endDate) {
    const lunar = Lunar.fromDate(currentDate);
    const solarTerm: string | null = lunar.getJieQi();

    if (solarTerm) {
      solarTerms.push({
        solarDate: `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月${currentDate.getDate()}日`,
        lunarDate: `${lunar.getYearInChinese()} ${lunar.getMonthInChinese()}${lunar.getDayInChinese()}`,
        solarTerm: solarTerm,
      });
    }

    currentDate.setDate(currentDate.getDate() + 1);
  }
  return solarTerms
}