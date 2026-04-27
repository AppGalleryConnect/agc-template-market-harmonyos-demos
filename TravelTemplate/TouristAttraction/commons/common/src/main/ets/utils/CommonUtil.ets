import { display } from '@kit.ArkUI';

export class CommonUtil {
  static padWithZeros(num: number) {
    if (num) {
      return num.toString().padStart(2, '0');
    }
    return '00';
  }

  static verifyPhoneNo(phone: string) {
    const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
    return phoneReg.test(phone);
  }

  static verifyCardNo(cardNo: string) {
    const cardNoReg = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/;
    return cardNoReg.test(cardNo);
  }

  // 判断是否是大折叠、阔折叠外屏、小折叠内屏
  static isDisplayModeFull(): boolean {
    // 是否可折叠
    let isFoldable = display.isFoldable();
    // 当前设备的显示模式
    let foldDisplayMode: display.FoldDisplayMode | undefined = undefined
    if (isFoldable) {
      foldDisplayMode = display.getFoldDisplayMode();
    }
    return foldDisplayMode === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL;
  }

  static getInitDates(currentYear: number, currentMonth: number, currentDay: number) {
    const result: Date[] = [];
    let count = 3
    if (CommonUtil.isDisplayModeFull()) {
      count = 7
    }

    // 创建当前日期对象
    const currentDate = new Date(currentYear, currentMonth, currentDay);

    for (let i = 0; i < count; i++) {
      const targetDate = new Date(currentDate);
      targetDate.setDate(targetDate.getDate() + i);
      result.push(new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate()));
    }

    return result;
  }

  static getFormatTime(date: Date) {
    let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    let currentDay = date.getDate(); // 获取当前日
    let currentYear = date.getFullYear();
    let currentHour = date.getHours();
    let currentMinutes = date.getMinutes();
    let currentSeconds = date.getSeconds();
    return `${currentYear}-${CommonUtil.padWithZeros(currentMonth)}-${CommonUtil.padWithZeros(currentDay)} ${CommonUtil.padWithZeros(currentHour)}:${CommonUtil.padWithZeros(currentMinutes)}:${CommonUtil.padWithZeros(currentSeconds)}`;
  }

  static getFormatDate(date: Date) {
    let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    let currentDay = date.getDate(); // 获取当前日
    let currentYear = date.getFullYear();
    return `${currentYear}-${CommonUtil.padWithZeros(currentMonth)}-${CommonUtil.padWithZeros(currentDay)}`;
  }

  static getValidEndTime(startDate: Date) {
    return `${startDate.getFullYear()}-${CommonUtil.padWithZeros(startDate.getMonth() +
      1)}-${CommonUtil.padWithZeros(startDate.getDate())}`;
  }
}