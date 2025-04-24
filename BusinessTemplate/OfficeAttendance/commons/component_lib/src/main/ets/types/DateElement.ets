@ObservedV2
export class DateElement {
  @Trace day: number = -1;
  @Trace month: number = -1;
  @Trace year: number = -1;

  constructor(year: number, month: number, day: number) {
    this.day = day;
    this.month = month;
    this.year = year;
  }

  isEquals(d: DateElement): boolean {
    return d.day === this.day && d.month === this.month && d.year === this.year;
  }

  getDateString(): string {
    const pad = (n: number) => (n < 10 ? '0' + n : n.toString());
    let dateStr = '';
    if (this.year && this.year > 0) {
      dateStr = dateStr + this.year;
    }
    if (this.month && this.month > -1) {
      dateStr = dateStr + '-' + pad(this.month + 1);
    }
    if (this.day && this.day > -1) {
      dateStr = dateStr + '-' + pad(this.day);
    }
    return dateStr;
  }

  getDate() {
    if (this.day > -1) {
      return new Date(this.year, this.month, this.day);
    }
    return new Date();

  }
}