export class Constants {
  static readonly REPEAT_TYPE =
    new Map([[1, $r('app.string.schedule_repeat_no')], [5, $r('app.string.schedule_repeat_day')],
      [4, $r('app.string.schedule_repeat_week')], [3, $r('app.string.schedule_repeat_month')],
      [2, $r('app.string.schedule_repeat_year')]]);
  static readonly REMINDER_TYPE =
    new Map([[0, $r('app.string.reminder_on_time')], [5, $r('app.string.reminder_before_5min')],
      [10, $r('app.string.reminder_before_10min')], [15, $r('app.string.reminder_before_15min')],
      [30, $r('app.string.reminder_before_30min')], [60, $r('app.string.reminder_before_1h')],
      [120, $r('app.string.reminder_before_2h')], [1440, $r('app.string.reminder_before_1d')],
      [2880, $r('app.string.reminder_before_2d')]]);
  static readonly REMINDER_TYPE_4DAY =
    new Map([[0, $r('app.string.reminder_on_day_9clock')], [1, $r('app.string.reminder_before_1day_9clock')],
      [2, $r('app.string.reminder_before_2day_9clock')], [3, $r('app.string.reminder_before_3day_9clock')],
      [4, $r('app.string.reminder_before_1week_9clock')]]);

  static readonly NO_REPEAT = 1;
  static readonly REMINDER_MINUTES_30 = 30;
  static readonly REMINDER_ON_DAY_9CLOCK = 0;
}
