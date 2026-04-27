import dayjs from 'dayjs';
import { Solar } from 'lunar';

/**
 * 生成随机id
 */
export function generateId() {
  return Math.random().toString(36).substring(2, 9)
}

/**
 * 计算下一次生日日期
 */
export function getNextBirthday(birthday: Date): Date {
  const today = new Date();
  const thisYearBirthday = new Date(
    today.getFullYear(),
    birthday.getMonth(),
    birthday.getDate(),
    birthday.getHours(),
    birthday.getMinutes(),
    birthday.getSeconds(),
  );
  return thisYearBirthday < today
    ? new Date(thisYearBirthday.getFullYear() + 1, thisYearBirthday.getMonth(), thisYearBirthday.getDate())
    : thisYearBirthday;
}

export function compareDates(start: Date, end: Date) {
  const timestamp1 = start.getTime()
  const timestamp2 = end.getTime()

  if (timestamp1 > timestamp2) {
    return false
  }
  return true
}


export function solarToLunar(date: Date): string {
  const year = dayjs(date).year()
  const month = dayjs(date).month() + 1
  const day = dayjs(date).date()
  const solar = Solar.fromDate(new Date(year, month - 1, day));
  const lunar = solar.getLunar();
  return `${year}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`;
}

/**
 * 计算距离生日还有多少天
 * @param birthdayStr 生日日期字符串，格式支持 'YYYY-MM-DD' 或 'MM-DD'
 * @returns 距离生日的天数描述
 */
export function calculateDaysUntilBirthday(birthdayStr: string): number {
  const today = new Date();
  const currentYear = today.getFullYear();
  const currentMonth = today.getMonth() + 1;
  const currentDay = today.getDate();

  let birthdayMonth: number, birthdayDay: number;
  const parts = birthdayStr.split('-');
  birthdayMonth = parseInt(parts[parts.length - 2], 10);
  birthdayDay = parseInt(parts[parts.length - 1], 10);

  const birthdayThisYear = new Date(currentYear, birthdayMonth - 1, birthdayDay);
  const todayZero = new Date(currentYear, currentMonth - 1, currentDay);

  if (
    birthdayThisYear.getFullYear() === todayZero.getFullYear() &&
      birthdayThisYear.getMonth() === todayZero.getMonth() &&
      birthdayThisYear.getDate() === todayZero.getDate()
  ) {
    return 0;
  }

  let targetBirthday: Date;
  if (birthdayThisYear < todayZero) {
    targetBirthday = new Date(currentYear + 1, birthdayMonth - 1, birthdayDay);
  } else {
    targetBirthday = birthdayThisYear;
  }

  const timeDiff = targetBirthday.getTime() - todayZero.getTime();
  const daysDiff = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));

  return daysDiff;

}
