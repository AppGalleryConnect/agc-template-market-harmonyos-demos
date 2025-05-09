import { getDayLabel } from 'common';
import { FlightInfo } from '../model/FlightPageModel';

// 获取飞行时长
export function getFlyDuration(flight: FlightInfo) {
  let start = new Date(flight.takeoffTime).getTime()
  let end = new Date(flight.landingTime).getTime()
  let diff = end - start
  const totalMinutes = Math.floor(diff / (1000 * 60));
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}h${minutes}min`;
}

// 判断是否是次日
export function isNextDay(flight: FlightInfo): boolean {
  const depDate = new Date(flight.takeoffTime).toDateString();
  const arrDate = new Date(flight.landingTime).toDateString();
  return depDate !== arrDate;
}

// 获取出发日期是星期几
export function getWeekDay(time: string): string {
  return `${getDayLabel(new Date(time))}`
}