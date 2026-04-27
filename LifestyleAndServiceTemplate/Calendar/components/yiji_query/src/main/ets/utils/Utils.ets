import dayjs from 'dayjs';
import { Lunar } from 'lunar';
import { weekdayMap } from '../constants/Constants';
import { LuckyDays, PickerDate } from '../model/Model';

export function getLuckyMarriageDaysInTwoMonths(title: string, choose: string, start: Date, end?: Date) {
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
    let condition = choose === 'yi' ? lunar.getDayYi() : lunar.getDayJi()
    if (condition.includes(title)) {
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

export function getCurEndDate(currentDate: string | Date,type?:string) {
  const dateObj = new Date(currentDate);
  const twoMonthsLater = new Date(dateObj);
  if(!type){
    twoMonthsLater.setMonth(dateObj.getMonth() + 2);
  }
  let twoMonthsFormat:PickerDate = getCurSolarDate(twoMonthsLater)
  return twoMonthsFormat;
}

export function getCurSolarDate(date?: Date):PickerDate {
  const dateObj = dayjs(date);
  const currentDate = dateObj.format('YYYY.M.D');
  const weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][dateObj.day()];
  const lunar = Lunar.fromDate(dateObj.toDate());
  const lunarMonth = lunar.getMonthInChinese();
  const lunarDay = lunar.getDayInChinese()
  const lunarDate = `${lunarMonth}月${lunarDay}`;
  return {
    currentDate,
    weekday,
    lunarDate
  }
}
