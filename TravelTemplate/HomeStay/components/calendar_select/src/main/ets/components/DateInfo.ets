import { common } from '@kit.AbilityKit';
import { Constants } from '../constant/Constants';
import { DateModel, Price } from '../model/DateModel';
import { CustomCalendarPickerDialog } from './CustomCalendarPickerDialog';
import { CalendarUtil } from '../utils/CalendarUtil';

@ComponentV2
export struct DateInfo {
  @Param @Require priceList: Price[] = [];
  @Local startMonth: number = CalendarUtil.getStartDate().month;
  @Local startDay: number = CalendarUtil.getStartDate().day;
  @Local startWeek: number = CalendarUtil.getStartDate().week;
  @Local endMonth: number = CalendarUtil.getEndDate().month;
  @Local endDay: number = CalendarUtil.getEndDate().day;
  @Local endWeek: number = CalendarUtil.getEndDate().week;
  @Local isShowSheet: boolean = false;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.context.eventHub.on('update_date', (startDate: DateModel, endDate: DateModel) => {
      this.startMonth = startDate.month;
      this.startDay = startDate.day;
      this.startWeek = startDate.week;
      this.endMonth = endDate.month;
      this.endDay = endDate.day;
      this.endWeek = endDate.week;
    });
  }

  handleConfirm(startDate: DateModel, endDate: DateModel) {
    let night: number;
    if (startDate.month === endDate.month) {
      night = endDate.day - startDate.day;
    } else {
      let currentMonthDays = this.getMonthDayCount(startDate.month, startDate.year);
      night = currentMonthDays - startDate.day + endDate.day;
    }
    CalendarUtil.setStartDate(startDate);
    CalendarUtil.setEndDate(endDate);
    CalendarUtil.setNight(night);
    this.context.eventHub.emit('update_date', startDate, endDate);
    this.isShowSheet = false;
  }

  getMonthDayCount(month: number, year: number): number {
    return new Date(year, month, 0).getDate();
  }

  @Builder
  calendarSheetBuilder() {
    CustomCalendarPickerDialog({
      priceList: this.priceList,
      onClose: () => {
        this.isShowSheet = false;
      },
      onConfirm: (startDate: DateModel, endDate: DateModel) => {
        this.handleConfirm(startDate, endDate);
      },
    });
  }

  build() {
    Row() {
      Column({ space: 20 }) {
        Text('入住日期')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(14);
        Row({ space: 8 }) {
          Text(`${this.startMonth}月${this.startDay}日`)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium);
          Text(`周${Constants.WEEK[this.startWeek]}`)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(14);
        }
      };

      Column({ space: 20 }) {
        Text(`共${CalendarUtil.getNight()}晚`)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(14);
        Text('——')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(14);
      }.justifyContent(FlexAlign.Center);

      Column({ space: 20 }) {
        Text('离店日期')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(14);
        Row({ space: 8 }) {
          Text(`${this.endMonth}月${this.endDay}日`)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium);
          Text(`周${Constants.WEEK[this.endWeek]}`)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(14);
        }
      };
    }
    .justifyContent(FlexAlign.SpaceAround)
    .padding(16)
    .alignItems(VerticalAlign.Center)
    .width(Constants.FULL_SCREEN)
    .onClick(() => {
      this.isShowSheet = true;
    })
    .bindSheet($$this.isShowSheet, this.calendarSheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      showClose: false,
      dragBar: false,
      backgroundColor: $r('sys.color.background_primary'),
      onWillDisappear: () => {
        this.isShowSheet = false;
      },
    });
  }
}
