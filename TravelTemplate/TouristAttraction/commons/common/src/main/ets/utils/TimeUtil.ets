import { padWithZeros } from './CommonUtil';

export function getFormatTime(date: Date) {
  let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
  let currentDay = date.getDate(); // 获取当前日
  let currentYear = date.getFullYear();
  let currentHour = date.getHours();
  let currentMinutes = date.getMinutes();
  let currentSeconds = date.getSeconds();
  return `${currentYear}-${padWithZeros(currentMonth)}-${padWithZeros(currentDay)} ${padWithZeros(currentHour)}:${padWithZeros(currentMinutes)}:${padWithZeros(currentSeconds)}`;
}

export function getFormatDate(date: Date) {
  let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
  let currentDay = date.getDate(); // 获取当前日
  let currentYear = date.getFullYear();
  return `${currentYear}-${padWithZeros(currentMonth)}-${padWithZeros(currentDay)}`;
}

export function getValidEndTime(startDate: Date) {
  return `${startDate.getFullYear()}-${padWithZeros(startDate.getMonth() + 1)}-${padWithZeros(startDate.getDate())}`;
}

