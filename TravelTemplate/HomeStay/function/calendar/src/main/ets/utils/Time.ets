import { DateModel } from '../model/DateModel';

const SATURDAY = 6;

export function getMonthDate(specifiedMonth: number, specifiedYear: number): number[] {
  let currentFirstWeekDay: number = 0;
  let currentLastWeekDay: number = 0;
  let currentAllDay: number[] = [];
  let totalDays = new Date(specifiedYear, specifiedMonth, 0).getDate();
  currentFirstWeekDay = new Date(specifiedYear, specifiedMonth - 1, 1).getDay();
  currentLastWeekDay = new Date(specifiedYear, specifiedMonth - 1, totalDays).getDay();
  // 将月份中显示上个月日期的内容置0
  for (let item = 0; item < currentFirstWeekDay; item++) {
    currentAllDay[item] = 0;
  }
  // 将本月日期内容存入数组
  for (let item = 1; item <= totalDays; item++) {
    currentAllDay.push(item);
  }
  // 将月份中显示下个月日期的内容置0
  for (let item = 0; item < SATURDAY - currentLastWeekDay; item++) {
    currentAllDay.push(0);
  }
  return currentAllDay;
}

export function formatDate(value: number) {
  return value < 10 ? value.toString().padStart(2, '0') : value;
}

/*
 * 获取当前日期，年月日星期几
 */
export function getRealTimeDate(): DateModel {
  const nowDate = new Date(); // 创建Date对象,设置当前日期和时间
  let currentMonth = nowDate.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
  let currentDay = nowDate.getDate(); // 获取当前日
  let currentYear = nowDate.getFullYear(); // 获取当前年份
  let currentWeekDay = new Date(currentYear, currentMonth - 1, currentDay).getDay(); // 获取当前星期几
  let nowDateModel = new DateModel(0, 0, 0, 0); // 创建DateModel实例
  nowDateModel.day = currentDay;
  nowDateModel.week = currentWeekDay;
  nowDateModel.month = currentMonth;
  nowDateModel.year = currentYear;
  return nowDateModel;
}

export function getFormatDate(date: Date) {
  let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
  let currentDay = date.getDate(); // 获取当前日
  let currentYear = date.getFullYear();
  return `${currentYear}-${formatDate(currentMonth)}-${formatDate(currentDay)}`;
}

export function getDateByIncrement(increment: number) {
  const date = new Date(); // 创建Date对象,设置当前日期和时间
  let currentMonth = date.getMonth() + 1;
  let currentDay = date.getDate();
  let currentYear = date.getFullYear();
  let totalDays = new Date(currentYear, currentMonth, 0).getDate();
  if (currentDay + increment > totalDays) {
    if (currentMonth === 12) {
      currentYear += 1;
      currentDay = totalDays - currentDay + increment;
    } else {
      currentMonth += 1;
      currentDay = totalDays - currentDay + increment;
    }
  } else {
    currentDay = currentDay + increment;
  }

  return `${currentYear}-${formatDate(currentMonth)}-${formatDate(currentDay)}`;
}

export function getLastDayOfMonth(year: number, month: number) {
  let date = new Date(year, month + 1, 1);
  date.setDate(date.getDate() - 1);
  return date.getDate();
}


