import { DateElement } from './DateElement';

@ObservedV2
export class DateTimeElement extends DateElement {
  @Trace hour: number = -1;
  @Trace minute: number = -1;

  constructor(year: number, month: number, day: number, hour: number, minute: number) {
    super(year, month, day);
    this.hour = hour;
    this.minute = minute;
  }

  isEquals(d: DateTimeElement): boolean {
    return d.hour === this.hour && d.minute === this.minute && super.isEquals(d);
  }

  getDate() {
    if (this.hour > -1) {
      return new Date(this.year, this.month, this.day, this.hour, this.minute);
    }
    return new Date(this.year, this.month, this.day);
  }
}