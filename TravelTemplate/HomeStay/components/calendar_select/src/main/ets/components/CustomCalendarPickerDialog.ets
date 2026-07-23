import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants } from '../constant/Constants';
import { DateModel, DayInfo, Price } from '../model/DateModel';
import { getMonthDate, getRealTimeDate } from '../utils/Time';
import { CalendarUtil } from '../utils/CalendarUtil';

@ComponentV2
export struct CustomCalendarPickerDialog {
  @Param priceList: Price[] = [];
  @Event onClose: () => void = () => {};
  @Event onConfirm: (startDate: DateModel, endDate: DateModel) => void = () => {};
  @Local currentMonth: number = 0;
  @Local currentDay: number = 0;
  @Local currentYear: number = 0;
  @Local currentMonthDay: number[] = [];
  @Local currentMonthDaysInfo: DayInfo[] = [];
  @Local tempStartDate: DateModel = new DateModel();
  @Local tempEndDate: DateModel = new DateModel();
  @Local selectStep: number = 0;

  aboutToAppear() {
    let startDate = CalendarUtil.getStartDate();
    let endDate = CalendarUtil.getEndDate();
    this.tempStartDate = new DateModel(startDate.day, startDate.week, startDate.month, startDate.year);
    this.tempEndDate = new DateModel(endDate.day, endDate.week, endDate.month, endDate.year);

    if (this.tempEndDate.day !== 0) {
      this.selectStep = 2;
    }

    let currentDate: DateModel = getRealTimeDate() ?? new DateModel(0, 0, 0, 0);
    this.currentMonth = currentDate.month;
    this.currentDay = currentDate.day;
    this.currentYear = currentDate.year;

    this.currentMonthDay = getMonthDate(this.currentMonth, this.currentYear);
    this.currentMonthDaysInfo = this.getDaysInfo(this.currentMonthDay, this.currentMonth, this.currentYear);
  }

  getDaysInfo(day: number[], month: number, year: number): DayInfo[] {
    let daysInfo: DayInfo[] = [];
    day.forEach((item: number) => {
      let dayInfo = new DayInfo();
      let priceItem = this.priceList.find((priceItem: Price) => priceItem.date ===
        `${year}-${month < 10 ? month.toString().padStart(2, '0') : month}-${item < 10 ?
          item.toString().padStart(2, '0') : item}`);
      if (priceItem) {
        dayInfo.day = item;
        dayInfo.price = priceItem.price;
      } else {
        dayInfo.day = item;
        dayInfo.price = 0;
      }
      daysInfo.push(dayInfo);
    });
    return daysInfo;
  }

  isEnable(dayInfo: DayInfo) {
    if (dayInfo.day === 0) {
      return false;
    }
    return dayInfo.day >= this.currentDay;
  }

  isSelectedDay(dayInfo: DayInfo) {
    let isStart = dayInfo.day === this.tempStartDate.day && this.currentMonth === this.tempStartDate.month;
    let isEnd = dayInfo.day === this.tempEndDate.day && this.currentMonth === this.tempEndDate.month;
    return isStart || isEnd;
  }

  isInTravel(dayInfo: DayInfo) {
    if (this.tempEndDate.day === 0 || this.tempStartDate.day === 0) {
      return false;
    }
    if (dayInfo.day === 0) {
      return false;
    }
    if (this.tempStartDate.month === this.tempEndDate.month && this.currentMonth === this.tempStartDate.month) {
      return dayInfo.day > this.tempStartDate.day && dayInfo.day < this.tempEndDate.day;
    }
    if (this.currentMonth === this.tempStartDate.month) {
      return dayInfo.day > this.tempStartDate.day;
    }
    if (this.currentMonth === this.tempEndDate.month) {
      return dayInfo.day < this.tempEndDate.day;
    }
    return false;
  }

  isRangeStart(dayInfo: DayInfo) {
    if (this.tempEndDate.day === 0) {
      return false;
    }
    return dayInfo.day === this.tempStartDate.day && this.currentMonth === this.tempStartDate.month;
  }

  isRangeEnd(dayInfo: DayInfo) {
    if (this.tempEndDate.day === 0) {
      return false;
    }
    return dayInfo.day === this.tempEndDate.day && this.currentMonth === this.tempEndDate.month;
  }

  hasRangeLeft(dayInfo: DayInfo) {
    return this.isInTravel(dayInfo) || this.isRangeEnd(dayInfo);
  }

  hasRangeRight(dayInfo: DayInfo) {
    return this.isInTravel(dayInfo) || this.isRangeStart(dayInfo);
  }

  getFontColor(dayInfo: DayInfo) {
    if (this.isSelectedDay(dayInfo) || this.isInTravel(dayInfo)) {
      return $r('sys.color.font_on_primary');
    }
    if (dayInfo.day === 0 || !this.isEnable(dayInfo)) {
      return $r('sys.color.font_tertiary');
    }
    return $r('sys.color.font_primary');
  }

  getPriceFontColor(dayInfo: DayInfo) {
    if (this.isSelectedDay(dayInfo) || this.isInTravel(dayInfo)) {
      return $r('sys.color.font_on_primary');
    }
    return $r('sys.color.font_secondary');
  }

  build() {
    Column() {
      Row() {
        Text('选择日期')
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold);

        Blank();

        Image($r('app.media.ic_right_close'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.onClose();
        });
      }
      .width(Constants.FULL_SCREEN)
      .padding({ left: 16, right: 16, top: 16, bottom: 8 });

      Text(`${this.currentYear}年${this.currentMonth}月`)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .width(Constants.FULL_SCREEN)
        .textAlign(TextAlign.Start)
        .padding({ left: 16, top: 12, bottom: 8 });

      Grid() {
        ForEach(Constants.WEEK, (weekInformation: string) => {
          GridItem() {
            Text(weekInformation)
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'));
          }
          .height(33);
        }, (item: string) => item);

        ForEach(this.currentMonthDaysInfo, (dayInfo: DayInfo, index: number) => {
          GridItem() {
            Stack() {
              Row() {
                if (this.hasRangeLeft(dayInfo)) {
                  Row().width('50%').height(33).backgroundColor($r('sys.color.comp_emphasize_secondary'));
                } else {
                  Row().width('50%').height(33);
                }
                if (this.hasRangeRight(dayInfo)) {
                  Row().width('50%').height(33).backgroundColor($r('sys.color.comp_emphasize_secondary'));
                } else {
                  Row().width('50%').height(33);
                }
              }
              .width('100%')
              .height(33);

              Column({ space: 1 }) {
                Text(`${dayInfo.day ? dayInfo.day.toString() : ''}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getFontColor(dayInfo));

                if (this.priceList.length && dayInfo.price !== 0) {
                  Text(`￥${dayInfo.price}`)
                    .fontSize(8)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getPriceFontColor(dayInfo));
                }
              }
              .justifyContent(FlexAlign.Center)
              .width(33)
              .height(33)
              .borderRadius(this.isSelectedDay(dayInfo) ? 16.5 : 0)
              .backgroundColor(this.isSelectedDay(dayInfo) ? $r('sys.color.comp_background_emphasize') :
                Color.Transparent);
            }
            .width('100%')
            .height(33)
          }
          .enabled(this.isEnable(dayInfo))
          .onClick(() => {
            this.selectDate(dayInfo);
          });
        }, (item: DayInfo, index: number) => item.day.toString() + index.toString());
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(0)
      .width(Constants.FULL_SCREEN)
      .padding(16);

      Row({ space: 12 }) {
        Button('取消')
          .borderRadius($r('sys.float.corner_radius_level10'))
          .height(40)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.onClose();
          });

        Button('确定')
          .borderRadius($r('sys.float.corner_radius_level10'))
          .height(40)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .enabled(this.tempEndDate.day !== 0)
          .onClick(() => {
            this.onConfirm(this.tempStartDate, this.tempEndDate);
          });
      }
      .width(Constants.FULL_SCREEN)
      .padding({ left: 16, right: 16, top: 12, bottom: 44 });
    }
    .width(Constants.FULL_SCREEN)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius({
      topLeft: $r('sys.float.corner_radius_level8'),
      topRight: $r('sys.float.corner_radius_level8'),
    })
    .alignItems(HorizontalAlign.Center);
  }

  selectDate(dayInfo: DayInfo) {
    let weekIndex = this.currentMonthDay.indexOf(dayInfo.day) % Constants.WEEK_NUMBER;

    if (this.selectStep === 0 || this.selectStep === 2) {
      this.tempStartDate = new DateModel(dayInfo.day, weekIndex, this.currentMonth, this.currentYear);
      this.tempEndDate = new DateModel(0, 0, 0, 0);
      this.selectStep = 1;
      ToastDialog.showToast({ message: '请选择离店日期' });
    } else {
      if (dayInfo.day === this.tempStartDate.day && this.currentMonth === this.tempStartDate.month) {
        ToastDialog.showToast({ message: '入住日期与离店日期不能为同一天' });
        return;
      }

      let endDate = new DateModel(dayInfo.day, weekIndex, this.currentMonth, this.currentYear);

      if (this.tempStartDate.day > endDate.day) {
        let tmp = this.tempStartDate;
        this.tempStartDate = new DateModel(endDate.day, endDate.week, endDate.month, endDate.year);
        this.tempEndDate = new DateModel(tmp.day, tmp.week, tmp.month, tmp.year);
      } else {
        this.tempEndDate = endDate;
      }
      this.selectStep = 2;
    }
  }
}
