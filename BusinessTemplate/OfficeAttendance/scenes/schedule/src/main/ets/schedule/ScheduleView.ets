import { ScheduleInfo } from '../types/Types';
import {
  AppStorageData,
  CommonConstants,
  DataPreferencesUtils,
  DateUtils,
  DialogMap,
  FormatUtil,
  MainEntryVM,
  RouterModule
} from '@ohos_agcit/office_attendance_common_lib';
import { ScheduleTitle } from './components/ScheduleTitle';
import { DateElement } from '@ohos_agcit/office_attendance_component_lib/src/main/ets/types/DateElement';
import { CalenderView } from '@ohos_agcit/office_attendance_component_lib';
import { RequestProxy } from '../api/RequestProxy';
import { AppStorageV2 } from '@kit.ArkUI';
import { ScheduleItem } from './components/ScheduleItem';

@Preview
@ComponentV2
export struct ScheduleView {
  @Local myStorage: AppStorageData =
    AppStorageV2.connect(AppStorageData, CommonConstants.APP_STORAGE_DATA_KEY, () => new AppStorageData())!;
  scroller: Scroller = new Scroller()
  @Local selectedDay: DateElement = new DateElement(0, 0, 0);
  @Local selectedMonth: DateElement = new DateElement(DateUtils.getCurrentYear(), DateUtils.getCurrentMonth(), 0);
  @Local showYear: number = DateUtils.getCurrentYear();
  @Local showMonth: number = DateUtils.getCurrentMonth();
  @Local searchTxt: string | undefined;
  vm: MainEntryVM = MainEntryVM.instance;
  @Provider() schedules: ScheduleInfo[] = [];
  private viewType: number = CommonConstants.MONTH_VIEW;
  @Local hasScheduleDates: Array<string> = [];
  @Local isShowLunar: boolean = true;

  load() {
    let date = FormatUtil.formatDate(this.selectedDay.getDate(), FormatUtil.DATE_YYYY_MM_DD);
    RequestProxy.queryByDate(date).then((data) => {
      this.schedules = data;
    });
    RequestProxy.queryScheduleDates('', '').then((data) => {
      this.hasScheduleDates = data;
    });
  }

  aboutToAppear(): void {
    this.load();
  }

  @Monitor('showYear')
  onSelectedYearChange(monitor: IMonitor) {
    if (monitor.value()) {
      this.selectedMonth.year = monitor.value()?.now as number;
    }
  }

  @Monitor('showMonth')
  onSelectedMonthChange(monitor: IMonitor) {
    if (monitor.value()) {
      this.selectedMonth.month = monitor.value()?.now as number;
    }
  }

  changeMonth(selectedMonth: DateElement) {
    this.showYear = selectedMonth.year;
    this.showMonth = selectedMonth.month;
  }

  search(data: string) {
    if (data && data.length > 0) {
      this.searchTxt = data;
      RequestProxy.queryByName(this.searchTxt).then((data) => {
        this.schedules = data;
      });
    } else {
      this.searchTxt = undefined;
    }
  }

  newSchedule() {
    RouterModule.openDialog(DialogMap.NEW_SCHEDULE, {
      param: this.selectedDay,
      onPop: () => {
        this.load();
      }
    });
  }

  isSettingLunar() {
    return DataPreferencesUtils.LUNAR_SETTING_ON ===
    DataPreferencesUtils.getSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
  }

  changeLunar() {
    this.isShowLunar = this.isSettingLunar()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column().width('4%')
          Column() {
            Blank().height('2%').width('100%')

            Search({ placeholder: $r('app.string.search_tip') })
              .height(40)
              .width('100%')
              .textFont({ size: 16, weight: FontWeight.Regular })
              .margin({ top: 0, bottom: 0 })
              .onChange((data: string) => {
                this.search(data);
              })
              .onSubmit((data: string) => {
                this.search(data);
              })

            Blank().height('2%').width('100%')

            /*********日历-头部*********/
            Row() {
              ScheduleTitle({
                selectedMonth: this.selectedMonth,
                onChange: (selectedMonth: DateElement) => {
                  this.changeMonth(selectedMonth);
                },
                onLunarChange: () => {
                  this.changeLunar();
                }
              })
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .visibility(this.searchTxt ? Visibility.None : Visibility.Visible)

            /*********日历-日期*********/
            Row() {
              CalenderView({
                hasScheduleDates: this.hasScheduleDates,
                showMonth: new DateElement(this.showYear, this.showMonth, 0),
                isShowLunar: this.isShowLunar,
                onChangeDay: (day: DateElement) => {
                  this.selectedDay = day;
                  this.load();
                },
                onChangeMonth: (month: DateElement) => {
                  this.selectedMonth = month;
                  this.changeMonth(month);
                },
                onChangeViewType: (viewType: number) => {
                  this.viewType = viewType;
                }
              })
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .visibility(this.searchTxt ? Visibility.None : Visibility.Visible)
          }.layoutWeight(1)

          Column().width('4%')
        }

        Column() {
          Row()
            .width('100%')
            .height('1%')
            .shadow({
              radius: 10,
              color: $r('app.color.window_background'),
              offsetX: 0,
              offsetY: 20
            })
          Column().height('2%')
          Row() {
            Column().width('4%')
            Text(DateUtils.getLunarMonthDesc(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .opacity(0.9)
            Blank().width(8)
            Text(DateUtils.getCurrentLunarDayDesc(this.selectedDay.year, this.selectedDay.month,
              this.selectedDay.day, (lunarMonth: number, lunarDay: number) => {
                return DateUtils.LUNAR_DAY.get(lunarDay + '')
              }))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .opacity(0.9)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .width('100%')

          Column().height('2%')
        }.visibility(this.searchTxt ? Visibility.None : Visibility.Visible)

        Row() {
          Column().width('4%')

          Column() {
            /*********日历-日程*********/
            List({ space: 8, scroller: this.scroller }) {
              ForEach(this.schedules, (schedule: ScheduleInfo) => {
                ListItem() {
                  ScheduleItem({
                    schedule: schedule, refresh: () => {
                      this.load()
                    }
                  })
                }.width('100%')
              }, (schedule: ScheduleInfo) => JSON.stringify(schedule))
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .visibility(this.searchTxt ? Visibility.None : Visibility.Visible)


            List({ space: 10, scroller: this.scroller }) {
              ForEach(this.schedules, (schedule: ScheduleInfo) => {
                ListItem() {
                  ScheduleItem({
                    schedule: schedule, refresh: () => {
                      this.load()
                    }
                  })
                }.width('100%')
              }, (schedule: ScheduleInfo) => JSON.stringify(schedule))
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .visibility(this.searchTxt ? Visibility.Visible : Visibility.None)

          }.height('100%')
          .layoutWeight(1)

          Column().width('4%').height('100%')
        }.layoutWeight(1)
        .width('100%')
      }

      Image($r('app.media.ic_plus_filled'))
        .height(60)
        .width(60)
        .onClick(() => {
          this.newSchedule();
        })
        .position({ x: this.myStorage.windowWidthVp * 0.8, y: this.myStorage.windowHeightVp * 0.7 })
        .visibility(this.searchTxt ? Visibility.None : Visibility.Visible)

    }.backgroundColor(Color.White)
  }
}

