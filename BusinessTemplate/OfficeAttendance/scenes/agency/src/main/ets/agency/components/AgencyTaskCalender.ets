import { i18n } from '@kit.LocalizationKit';
import { CommonConstants, DialogMap, FormatUtil, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { DateElement, DateTimeElement, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
class ShowDays {
  @Trace showDays: DateElement [][] = [];
}

@Builder
export function AgencyTaskCalenderBuilder() {
  AgencyTaskCalender();
}

@ComponentV2
export struct AgencyTaskCalender {
  private calendar = i18n.getCalendar('en-US');
  @Local today: number = this.calendar.get('date');
  @Local currentMonth: number = this.calendar.get('month');
  @Local currentYear: number = this.calendar.get('year');
  @Local showMonth: number = this.currentMonth;
  @Local showYear: number = this.currentYear;
  @Local selectedTime: DateTimeElement =
    new DateTimeElement(this.currentYear, this.currentMonth, this.today, 18, 30);
  @Local opacityNum: number = 1;
  @Local planTime: string = '';
  showDays: ShowDays = new ShowDays();

  @Monitor('showMonth')
  onSelectedMonthChange(monitor: IMonitor) {
    this.refresh();
  }

  hide() {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.pop();
      },
    }, () => {
      this.opacityNum = 0;
    });
  }

  save() {
    if (this.selectedTime.year === 0) {
      promptAction.showToast({ message: $r('app.string.new_agency_time_tip') });
      return;
    }
    RouterModule.closeDialog({
      param: {
        dateTime: this.selectedTime,
      }
    });
  }

  selectTime() {
    RouterModule.openDialog(DialogMap.TIME_SELECTOR, {
      param: this.selectedTime,
      onPop: (data: PopInfo) => {
        this.selectedTime.hour = (data.result as ESObject).param.hour as number;
        this.selectedTime.minute = (data.result as ESObject).param.minute as number;
        this.planTime = FormatUtil.formatDate(this.selectedTime.getDate(), FormatUtil.DATE_24H_mm);
      }
    });
  }

  refresh() {
    this.showDays.showDays = [];
    this.calendar.set(this.showYear, this.showMonth, 0);
    let preMonth = this.showMonth - 1 >= 0 ? this.showMonth - 1 : 11;
    let preMonthYear = this.showMonth - 1 >= 0 ? this.showYear : this.showYear - 1;
    let preMonthDays: number = -this.calendar.compareDays(new Date(preMonthYear, preMonth, 0)) - 1;
    let nextMonth = this.showMonth + 1 < 12 ? this.showMonth + 1 : 0;
    let nextMonthYear = this.showMonth + 1 < 12 ? this.showYear : this.showYear + 1;
    let selectMonthDays: number = this.calendar.compareDays(new Date(nextMonthYear, nextMonth, 0));
    let firstDayOfWeek = this.calendar.get('day_of_week');
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
      weedDays.push(new DateElement(this.showYear, this.showMonth, i));
    }
    if (weedDays.length < 7) {
      let diffDays = 7 - weedDays.length;
      for (let i = 0; i < diffDays; i++) {
        weedDays.push(new DateElement(nextMonthYear, nextMonth, i + 1));
      }
    }
    this.showDays.showDays.push(weedDays);
  }

  aboutToAppear() {
    let param: DateTimeElement | undefined = RouterModule.getNavParam({ url: DialogMap.AGENCY_TASK_CALENDER }).param;
    if (param && param.year > 0) {
      this.selectedTime = param;
      this.showYear = this.selectedTime.year;
      this.showMonth = this.selectedTime.month;
    }
    this.planTime = FormatUtil.formatDate(this.selectedTime.getDate(), FormatUtil.DATE_24H_mm);
    this.refresh();
  }

  private isToday(day: DateElement): boolean {
    return this.today === day.day && this.currentMonth === day.month &&
      this.currentYear === day.year;
  }

  appendZero(num: number): string {
    return num < 10 ? '0' + num : '' + num;
  }

  private isSelectedDay(day: DateElement): boolean {
    return this.selectedTime.year === day.year && this.selectedTime.month === day.month &&
      this.selectedTime.day === day.day;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .opacity(this.opacityNum)
        .transition(
          TransitionEffect.OPACITY.animation({
            duration: 300,
            curve: Curve.Friction,
          })
        )
        .onClick(() => {
          this.hide();
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        Column() {
          Column() {

            Column() {
              Column()
                .width('48')
                .height(4)
                .backgroundColor('#000000')
                .opacity(0.2)
                .borderRadius(2)
            }.alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height(16)

            Row() {
              Column().width('3%')

              TitleBar({
                titleResID: 'app.string.setting_plan_time',
                hide: () => {
                  this.hide()
                }, callback: () => {
                  this.save()
                }
              }).layoutWeight(1)

              Column().width('3%')
            }

            Row() {
              Row() {
                Image($r('app.media.ic_public_small_left'))
                  .id('pre_month')
                  .height(24)
                  .width(12)
              }
              .margin({ left: 5 })
              .height('100%')
              .aspectRatio(1)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.showYear = this.showMonth - 1 >= 0 ? this.showYear : this.showYear - 1;
                this.showMonth = this.showMonth - 1 >= 0 ? this.showMonth - 1 : 11;
              })

              Text(`${this.showYear}-${this.showMonth + 1 >= 10 ? '' : '0'}${this.showMonth + 1}`)
                .fontSize(16)
                .fontColor(Color.Black)
              Row() {
                Image($r('app.media.ic_public_small_right'))
                  .id('next_month')
                  .height(24)
                  .width(12)
              }
              .height('100%')
              .aspectRatio(1)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.showYear = this.showMonth + 1 < 12 ? this.showYear : this.showYear + 1;
                this.showMonth = this.showMonth + 1 < 12 ? this.showMonth + 1 : 0;
              })

              Blank()
              Row() {
                Text($r('app.string.today'))
                  .id('today')
                  .fontColor(Color.Blue)
                  .fontSize(16)
                  .padding({ right: 24 })
              }
              .height('100%')
              .aspectRatio(1)
              .onClick(() => {
                if (this.showYear === this.currentYear && this.showMonth === this.currentMonth) {
                  return;
                }
                this.showYear = this.currentYear;
                this.showMonth = this.currentMonth;
              })
            }
            .width('100%')
            .height(56)

            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(CommonConstants.WEEK_TITLE, (str: Resource) => {
                Text(str)
                  .fontSize(14)
                  .fontColor(Color.Black)
                  .opacity(0.5)
                  .height(24)
                  .width(24)
                  .textAlign(TextAlign.Center)
              })
            }
            .width('100%')
            .padding({ left: 24, right: 24 })
          }

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.showDays.showDays, (weekDays: DateElement [], index) => {
              Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                ForEach(weekDays, (day: DateElement) => {
                  Text(`${day.day}`)
                    .height(24)
                    .width(24)
                    .textAlign(TextAlign.Center)
                    .fontSize(14)
                    .fontColor(this.isSelectedDay(day) ? Color.Black : this.isToday(day) ? Color.White : Color.Black)
                    .backgroundColor(this.isSelectedDay(day) ? '' :
                      this.isToday(day) ? $r('app.color.sys_default_blue') : '')
                    .borderColor(this.isSelectedDay(day) ? $r('app.color.sys_default_blue') : Color.White)
                    .borderWidth(this.isSelectedDay(day) ? 1 : 0)
                    .borderRadius(20)
                    .onClick(() => {
                      this.selectedTime.year = day.year;
                      this.selectedTime.month = day.month;
                      this.selectedTime.day = day.day;
                      this.showMonth = day.month;
                      this.showYear = day.year;
                    })
                })
              }
              .width('100%')
              .margin({ top: 16 })
            })
          }
          .padding({ left: 24, right: 24 })
          .width('100%')

          Row() {
            Row() {
              Text($r('app.string.select_plan_time')).width(80).height(50)
            }.justifyContent(FlexAlign.Start).width('50%')

            Row() {
              Text(this.planTime).width(50).height(50)
              Image($r('app.media.ic_public_small_right'))
                .height(24)
                .width(12)
            }.justifyContent(FlexAlign.End).width('50%')
          }.width('100%')
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            this.selectTime();
          })
        }
        .borderRadius({ topLeft: 32, topRight: 32 })
        .height('60%')
        .backgroundColor(Color.White)
      }
    }.mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    }).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}