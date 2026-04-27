import { Constants } from '../common/Constant';

export class DateTimeBase {
  public hourRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_HOUR, '时');
  }

  public minutesRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_MINUTE, '分');
  }

  public secondsRange(): string[] {
    return this.range(Constants.ZERO, Constants.MAX_MINUTE, '秒');
  }

  public range(start: number, end: number, unit: string): string[] {
    let min = (start > end) ? end : start;
    let max = (start > end) ? start : end;

    let range: string[] = [];
    for (let i = min; i <= max; i++) {
      range.push(i.toString() + unit);
    }
    return range;
  }

  public isLeapYear(year: number): boolean {
    if ((year % Constants.FOUR_HUNDRED === Number(Constants.ZERO)) ||
      (year % Constants.FOUR === Number(Constants.ZERO) && year % Constants.ONE_HUNDRED !== Number(Constants.ZERO))) {
      return true;
    }
    return false;
  }
}
