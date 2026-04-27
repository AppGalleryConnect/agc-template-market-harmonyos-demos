import { Constants } from '../common/Constant';
import { DateTimeBase } from './DateTimeBase';

export class DateTimeSolar extends DateTimeBase {
  private startYear: number = 1900;
  private endYear: number = 2025;

  public setYearRange(startYear: number, endYear: number) {
    let minYear = (startYear > endYear) ? endYear : startYear;
    let maxYear = (startYear > endYear) ? startYear : endYear;

    this.startYear = minYear;
    this.endYear = maxYear;
  }

  public getStartSolarYear(): number {
    return this.startYear;
  }

  public yearRange(): string[] {
    return this.range(this.startYear, this.endYear, '年');
  }

  public monthRange(): string[] {
    return this.range(Constants.ONE, Constants.CURRENT_MONTH, '月');
  }

  public dayRange(year: number, month: number): string[] {
    let mapDays = new Map<number, number>([
      [1, 31], [2, this.isLeapYear(year) ? 29 : 28], [3, 31], [4, 30], [5, 31], [6, 30],
      [7, 31], [8, 31], [9, 30], [10, 31], [11, 30], [12, 31]
    ]);

    return this.range(Constants.ONE, mapDays.get(month) ?? Constants.CURRENT_DAY, '日');
  }
}