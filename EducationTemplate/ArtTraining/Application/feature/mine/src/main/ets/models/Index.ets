export class CourseInCalendar {
  curWeek: number = 0;
  list: number[] = [];
}

@ObservedV2
export class DateBarItemModel {
  @Trace weekday: string;
  @Trace date: string;
  @Trace hasClass: boolean;

  constructor(weekday: string, date: string, hasClass: boolean) {
    this.weekday = weekday;
    this.date = date;
    this.hasClass = hasClass;
  }
}