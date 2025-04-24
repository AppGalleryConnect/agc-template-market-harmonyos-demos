import { RecurrenceFrequency } from '@ohos_agcit/office_attendance_common_lib';

export interface ScheduleInfo {
  id?: string,
  eventId?: number,
  title: string,

  //位置描述
  location?: string,

  //维度
  latitude?: number,

  //经度
  longitude?: number
  isAllDay?: boolean,
  startTime: string
  endTime: string,

  //重复规则，不填写，不重复
  recurrenceRule?: number,

  //日程提醒时间，单位为分钟。填写x分钟，即距开始时间提前x分钟提醒，不填时，默认为不提醒
  reminderTime?: number[],
  conflicting?: boolean,
  desc?: string
}

@ObservedV2
export class Day {
  @Trace day: number = 0;
  @Trace month: number = 0;
  @Trace year: number = 0;

  constructor(year: number, month: number, day: number) {
    this.day = day;
    this.month = month;
    this.year = year;
  }

  isEquals(d: Day): boolean {
    return d.day === this.day && d.month === this.month && d.year === this.year;
  }

  getDay() {
    return this.year
  }
}

@ObservedV2
export class DayTime extends Day {
  @Trace hour: number = 0;
  @Trace minute: number = 0;

  constructor(year: number, month: number, day: number, hour: number, minute: number) {
    super(year, month, day);
    this.hour = hour;
    this.minute = minute;
  }

  isEquals(d: DayTime): boolean {
    return d.hour === this.hour && d.minute === this.minute && super.isEquals(d);
  }
}

