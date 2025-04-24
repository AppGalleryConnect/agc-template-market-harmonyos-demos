import { Constant } from '../constants/Constant';

export function getInitDates(currentYear: number, currentMonth: number, currentDay: number) {
  let currentMaxDay = new Date(currentYear, currentMonth, 0).getDate();
  let currentDate = new Date(currentYear, currentMonth, currentDay);
  let nextDate = new Date(0, 0, 0);
  let afterNextDay = new Date(0, 0, 0);
  if (currentDay === currentMaxDay) {
    if (currentMonth === Constant.LAST_MONTH) {
      //为12月，下一天为下一年
      nextDate = new Date(currentYear + 1, Constant.FIRST, Constant.FIRST);
      afterNextDay = new Date(currentYear + 1, Constant.FIRST, Constant.FIRST + 1);
    } else {
      nextDate = new Date(currentYear, currentMonth + 1, Constant.FIRST);
      nextDate = new Date(currentYear, currentMonth + 1, Constant.FIRST + 1);
    }
  } else {
    nextDate = new Date(currentYear, currentMonth, currentDay + 1);
    afterNextDay = new Date(currentYear, currentMonth, currentDay + 2);
  }
  return [currentDate, nextDate, afterNextDay];
}