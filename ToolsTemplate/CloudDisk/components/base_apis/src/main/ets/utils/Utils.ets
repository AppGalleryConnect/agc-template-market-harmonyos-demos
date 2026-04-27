import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { Lunar } from 'lunar';


export function getWeekday(dateStr: Date) {
  const days = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  return days[dateStr.getDay()];
}

function bufferToString(buffer: ArrayBufferLike): string {
  let textDecoder = util.TextDecoder.create('utf-8', {
    ignoreBOM: true
  });
  let resultPut = textDecoder.decodeToString(new Uint8Array(buffer), {
    stream: true
  });
  return resultPut;
}

export function getDataFromJSON<T>(rawFileName: string, component?: Object): T[] {
  let result: T[] = [];
  try {
    let value: Uint8Array = getContext(component).resourceManager.getRawFileContentSync(rawFileName);
    result = JSON.parse(bufferToString(value.buffer)) as T[];
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    console.error(`getRawFileContentSync failed, error code: ${code}, message: ${message}.`);
  }

  return result;
}

export function getDaysDiff(start: Date, end: Date): number {
  const startMidnight = new Date(start.getFullYear(), start.getMonth(), start.getDate());
  const endMidnight = new Date(end.getFullYear(), end.getMonth(), end.getDate());
  const diffMs = endMidnight.getTime() - startMidnight.getTime();
  return Math.floor(diffMs / (1000 * 3600 * 24));
}

export function yangLiToLunar(date: Date) {
  const lunar = Lunar.fromDate(date);
  let year = lunar.getYearInGanZhi()
  let month = lunar.getMonthInChinese()
  let day = lunar.getDayInChinese()
  return `${year}-${month}-${day}`
}