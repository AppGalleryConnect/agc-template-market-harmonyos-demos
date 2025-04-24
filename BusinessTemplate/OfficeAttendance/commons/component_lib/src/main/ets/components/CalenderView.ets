import { i18n } from '@kit.LocalizationKit';
import { CommonConstants, DateUtils } from '@ohos_agcit/office_attendance_common_lib';
import { DateElement } from '../types/DateElement';

@ObservedV2
class ShowDays {
  @Trace showDays: DateElement [][] = [];
  @Trace showWeekDays: DateElement [][] = [];
}

@ComponentV2
export struct CalenderView {
  @Param isShowLunar: boolean = true;
  @Param fontSize: Resource = $r('app.float.calendar_title_font_size')
  @Param titleFontOpacity: Resource = $r('app.float.calendar_title_font_opacity')
  @Param contentFontOpacity: Resource = $r('app.float.calendar_content_font_opacity')
  @Param weekendFontOpacity: Resource = $r('app.float.calendar_weekend_font_opacity')
  @Param beforeDateFontOpacity: Resource = $r('app.float.calendar_before_date_font_opacity')
  @Param todayFontOpacity: Resource = $r('app.float.calendar_today_font_opacity')
  readonly TIME_DEF_VALUE = -1;
  private calendar = i18n.getCalendar(CommonConstants.EN_LOCALE);
  @Local today: number = this.calendar.get(CommonConstants.FIELD_DAY);
  @Local currentMonth: number = this.calendar.get(CommonConstants.FIELD_MONTH);
  @Local currentYear: number = this.calendar.get(CommonConstants.FIELD_YEAR);
  @Param selectedDay: DateElement = new DateElement(0, 0, this.TIME_DEF_VALUE);
  @Event onChangeDay: (val: DateElement) => void = (val: DateElement) => {
  };
  @Param showMonth: DateElement = new DateElement(this.TIME_DEF_VALUE, this.TIME_DEF_VALUE, this.TIME_DEF_VALUE);
  @Event onChangeMonth: (showMonth: DateElement) => void = (showMonth: DateElement) => {
  };
  @Param showDotDate: Array<string> = []
  @Local viewType: number = CommonConstants.MONTH_VIEW;
  @Event onChangeViewType: (showType: number) => void = (showType: number) => {
  };
  @Param hasScheduleDates: Array<string> = [];
  showDays: ShowDays = new ShowDays();

  @Monitor('showMonth','selectedDay')
  onSelectedMonthChange(monitor: IMonitor) {
    this.refresh();
  }

  isWeekends(index: number) {
    return index === CommonConstants.COMMON_ZERO || index === CommonConstants.COMMON_SIX;
  }

  refresh() {
    this.init();
    this.calendar.set(this.showMonth.year, this.showMonth.month, 0);
    let preMonth = this.showMonth.month - 1 >= 0 ? this.showMonth.month - 1 : 11;
    let preMonthYear = this.showMonth.month - 1 >= 0 ? this.showMonth.year : this.showMonth.year - 1;
    let preMonthDays: number = -this.calendar.compareDays(new Date(preMonthYear, preMonth, 0)) - 1;
    let nextMonth = this.showMonth.month + 1 < 12 ? this.showMonth.month + 1 : 0;
    let nextMonthYear = this.showMonth.month + 1 < 12 ? this.showMonth.year : this.showMonth.year + 1;
    let selectMonthDays: number = this.calendar.compareDays(new Date(nextMonthYear, nextMonth, 0));
    let firstDayOfWeek = this.calendar.get(CommonConstants.FIELD_DAY_OF_WEEK);
    let weedDays: DateElement [] = [];
    let diffDays = firstDayOfWeek < 7 ? firstDayOfWeek : 0;

    for (let i = 1; i <= diffDays; i++) {
      weedDays.push(new DateElement(preMonthYear, preMonth, preMonthDays - diffDays + i));
    }
    for (let i = 1; i <= selectMonthDays; i++) {
      if (weedDays.length === 7) {
        this.showDays.showDays.push(weedDays);
        weedDays = [];
      }
      weedDays.push(new DateElement(this.showMonth.year, this.showMonth.month, i));
    }
    if (weedDays.length < 7) {
      let diffDays = 7 - weedDays.length;
      for (let i = 0; i < diffDays; i++) {
        weedDays.push(new DateElement(nextMonthYear, nextMonth, i + 1));
      }
    }
    this.showDays.showDays.push(weedDays);

    if (this.selectedDay.year !== this.showMonth.year || this.selectedDay.month !== this.showMonth.month) {
      this.selectedDay.year = this.showMonth.year;
      this.selectedDay.month = this.showMonth.month;
      this.onChangeDay(this.selectedDay);
    }
    if (this.selectedDay.day === this.TIME_DEF_VALUE) {
      this.selectedDay.day = this.today;
      this.onChangeDay(this.selectedDay);
    }
    this.setWeedViewData()
  }

  setWeedViewData() {
    this.showDays.showDays.forEach(week => {
      week.forEach(day => {
        if (this.isSelectedDay(day)) {
          this.showDays.showWeekDays = [week];
        }
      })
    })
  }

  init() {
    this.showDays.showDays = [];
    if (this.showMonth.year === this.TIME_DEF_VALUE) {
      this.showMonth.year = this.currentYear;
      this.showMonth.month = this.currentMonth;
      this.onChangeMonth(this.showMonth);
    }
  }

  aboutToAppear() {
    this.refresh();
  }

  private isToday(day: DateElement): boolean {
    return this.today === day.day && this.currentMonth === day.month &&
      this.currentYear === day.year;
  }

  isBeforeDay(day: DateElement) {
    return this.calendar.compareDays(new Date(day.year, day.month, day.day)) < 0;
  }

  appendZero(num: number): string {
    return num < 10 ? '0' + num : '' + num;
  }

  private isSelectedDay(day: DateElement): boolean {
    return this.selectedDay.isEquals(day);
  }

  isCurrentMonth(day: DateElement) {
    return this.showMonth.year === day.year && this.showMonth.month === day.month;
  }

  private changeMonthByGesture(e: GestureEvent) {
    if (e.offsetX > 10) {
      if (this.viewType === CommonConstants.MONTH_VIEW) {
        this.showMonth.year = this.showMonth.month - 1 < 0 ? this.showMonth.year - 1 : this.showMonth.year;
        this.showMonth.month = this.showMonth.month - 1 < 0 ? 11 : this.showMonth.month - 1;
        this.onChangeMonth(this.showMonth);
      } else {
        let selectedDate = new Date(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
        selectedDate = new Date(selectedDate.getTime() - CommonConstants.SEVEN_DAY);
        this.changeSelectDay(new DateElement(selectedDate.getFullYear(),
          selectedDate.getMonth(),
          selectedDate.getDate()))
      }
    } else if (e.offsetX < -10) {
      if (this.viewType === CommonConstants.MONTH_VIEW) {
        this.showMonth.year = this.showMonth.month + 1 < 12 ? this.showMonth.year : this.showMonth.year + 1;
        this.showMonth.month = this.showMonth.month + 1 < 12 ? this.showMonth.month + 1 : 0;
        this.onChangeMonth(this.showMonth);
      } else {
        let selectedDate = new Date(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
        selectedDate = new Date(selectedDate.getTime() + CommonConstants.SEVEN_DAY);
        this.changeSelectDay(new DateElement(selectedDate.getFullYear(),
          selectedDate.getMonth(),
          selectedDate.getDate()))
      }
    }
  }

  changeSelectDay(day: DateElement) {
    this.selectedDay.year = day.year;
    this.selectedDay.month = day.month;
    this.selectedDay.day = day.day;
    this.onChangeDay(day);
    this.setWeedViewData();
    this.changeMonth(day);
  }

  changeMonth(month: DateElement) {
    this.showMonth.year = month.year;
    this.showMonth.month = month.month;
    this.onChangeMonth(month);
  }

  isHasSchedule(day: DateElement) {
    let dayStr: string = day.getDateString();
    return this.hasScheduleDates.filter(t => {
      return t.indexOf(dayStr) > -1;
    }).length > 0;
  }

  build() {
    Column() {
      Column() {
        /****日期--周***/
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(CommonConstants.WEEK_TITLE, (str: Resource, index: number) => {
            Column() {
              Text(str)
                .fontSize(this.fontSize)
                .fontWeight(FontWeight.Regular)
                .textAlign(TextAlign.Center)
                .opacity(this.titleFontOpacity)
            }
            .justifyContent(FlexAlign.Center)
            .width($r('app.float.content_size'))
            .height($r('app.float.height_or_line_height'))
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius($r('app.float.height_or_line_height'))
        .margin({
          bottom: $r('app.float.day_button_radius'),
          left: CommonConstants.COMMON_MARGIN,
          right: CommonConstants.COMMON_MARGIN
        })
      }

      /****日期--天***/
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.viewType === CommonConstants.MONTH_VIEW ? this.showDays.showDays : this.showDays.showWeekDays,
          (weekDays: DateElement []) => {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(weekDays, (day: DateElement, index: number) => {
                Column() {
                  Text(`${day.day}`)
                    .fontSize(this.fontSize)
                    .fontWeight(FontWeight.Medium)
                    .opacity(this.isToday(day) ? this.todayFontOpacity :
                      this.isWeekends(index) ? this.weekendFontOpacity :
                        this.isCurrentMonth(day) ? this.contentFontOpacity : this.beforeDateFontOpacity)
                    .fontColor(this.isToday(day) && !this.isSelectedDay(day) ? $r('app.color.start_window_background') :
                    $r('app.color.black'))
                  Text(DateUtils.getCurrentLunarDayDesc(day.year, day.month, day.day))
                    .fontSize(this.fontSize)
                    .fontWeight(FontWeight.Medium)
                    .visibility(this.isShowLunar ? Visibility.Visible : Visibility.None)
                    .opacity(this.isToday(day) ? this.todayFontOpacity :
                      this.isWeekends(index) ? this.weekendFontOpacity :
                        this.isCurrentMonth(day) ? this.contentFontOpacity : this.beforeDateFontOpacity)
                    .fontColor(this.isToday(day) && !this.isSelectedDay(day) ? $r('app.color.start_window_background') :
                    $r('app.color.black'))

                  Column()
                    .width(4)
                    .height(4)
                    .borderRadius(2)
                    .backgroundColor(this.isSelectedDay(day) ? $r('app.color.sys_default_blue') :
                      this.isToday(day) ? Color.White : $r('app.color.sys_default_blue'))
                    .visibility(this.isHasSchedule(day) ? Visibility.Visible : Visibility.None)
                }
                .onClick(() => {
                  this.changeSelectDay(day);
                })
                .backgroundColor(this.isToday(day) && !this.isSelectedDay(day) ? $r('app.color.sys_default_blue') :
                Color.White)
                .borderRadius($r('app.float.schedule_border_radius'))
                .borderColor(this.isSelectedDay(day) ? $r('app.color.sys_default_blue') : Color.White)
                .borderWidth(this.isSelectedDay(day) ? 1 : 0)
                .justifyContent(FlexAlign.Center)
                .width($r('app.float.content_size'))
                .height($r('app.float.content_size'))
              })
            }
            .width('100%')
            .margin({ top: '6vp' })
          })
      }
      .width('100%')
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 5 })
        .onActionEnd((e: GestureEvent) => {
          this.changeMonthByGesture(e);
        })
      )

      Column().height('2%')

      Column() {
        Image($r('app.media.ic_chevron_up'))
          .width(64)
          .height(16)
          .visibility(this.viewType === CommonConstants.MONTH_VIEW ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.viewType = CommonConstants.WEEK_VIEW
            this.onChangeViewType(this.viewType)
          })
        Image($r('app.media.ic_chevron_down'))
          .width(64)
          .height(16)
          .visibility(this.viewType === CommonConstants.WEEK_VIEW ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.viewType = CommonConstants.MONTH_VIEW
            this.onChangeViewType(this.viewType)
          })
      }.height(16)
      .width('100%')
    }
  }
}