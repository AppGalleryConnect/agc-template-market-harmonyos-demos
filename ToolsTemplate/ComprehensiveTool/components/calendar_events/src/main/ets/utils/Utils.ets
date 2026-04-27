import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { SafeRandom } from '@hw-agconnect/petal-aegis';
import dayjs from 'dayjs';
import { Solar } from 'lunar';

/**
 * 生成随机id
 */
export function generateId() {
  /*
   * 生成安全随机数
   * */
  let hexString = SafeRandom.ohAegRandomHex(2)
  let decimalValue = 0;
  const hexChars = '0123456789ABCDEF';

  for (let char of hexString) {
    const value = hexChars.indexOf(char);
    decimalValue = decimalValue * 16 + value;
  }
  return Math.abs(decimalValue).toString();
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

export function getWeekday(dateStr: Date) {
  const days = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  return days[dateStr.getDay()];
}


export function getDaysDiff(start: Date, end: Date): number {
  const startMidnight = new Date(start.getFullYear(), start.getMonth(), start.getDate());
  const endMidnight = new Date(end.getFullYear(), end.getMonth(), end.getDate());
  const diffMs = endMidnight.getTime() - startMidnight.getTime();
  return Math.floor(diffMs / (1000 * 3600 * 24));
}


function bufferToString(buffer: ArrayBufferLike): string {
  let textDecoder = util.TextDecoder.create('utf-8', {
    ignoreBOM: true,
  });
  let resultPut = textDecoder.decodeToString(new Uint8Array(buffer), {
    stream: true,
  });
  return resultPut;
}

export function getDataFromJSON<T>(rawFileName: string, uiContext: UIContext, component?: Object): T[] {
  let result: T[] = [];
  try {
    let value: Uint8Array = uiContext.getHostContext()!.resourceManager.getRawFileContentSync(rawFileName);
    result = JSON.parse(bufferToString(value.buffer)) as T[];
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    console.error(`getRawFileContentSync failed, error code: ${code}, message: ${message}.`);
  }

  return result;
}

export function solarToLunar(date: Date): string {
  const year = dayjs(date).year()
  const month = dayjs(date).month() + 1
  const day = dayjs(date).date()
  const solar = Solar.fromDate(new Date(year, month - 1, day));
  const lunar = solar.getLunar();
  return `${year}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`;
}