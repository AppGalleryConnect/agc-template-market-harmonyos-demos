import { CommonConstants, Record, ExerciseRecord } from 'lib_common';
import { RecordPageVM } from '../viewmodels/RecordPageVM';
import { MOCK_BAR_CHART_LIST } from '../preview/Mockdata';
import { BarItem, DayBarChart, MonthBarChart, WeekBarChart, YearBarChart } from 'module_chart';
import { NavHeaderBar } from 'lib_widget';
import { AppStorageV2, TabSegmentButtonV2 , SegmentButtonV2Items, ColorMetrics } from '@kit.ArkUI';

@Builder
export function RecordPageBuilder() {
  RecordPage()
}

@ComponentV2
struct RecordPage {
  vm: RecordPageVM = new RecordPageVM();
  @Local textItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '周' },
    { text: '月' },
    { text: '年' },
  ]);
  @Local monthNames: string[] = [
    '1月', '2月', '3月', '4月', '5月', '6月',
    '7月', '8月', '9月', '10月', '11月', '12月'
  ];
  @Local textSelectedIndex: number = 0;
  @Local weekdayList: string[] = []
  @Local showWeekDates: string[] = [];
  @Local monthDayList: string[] = []
  @Local weekRecord: BarItem[] = []
  @Local monthRecord: BarItem[] = []
  @Local yearRecord: BarItem[] = []
  @Local defaultRecord: Record = { duration: 0, energy: 0 };
  @Local weekDuration: number = 0
  @Local weekEnergy: number = 0
  @Local weekDays: number = 0
  @Local monthDuration: number = 0
  @Local monthEnergy: number = 0
  @Local monthDays: number = 0
  @Local yearDuration: number = 0
  @Local yearEnergy: number = 0
  @Local yearDays: number = 0

  aboutToAppear(): void {
    this.weekdayList = this.buildDateList()
    this.monthDayList = this.buildMonthList()
    this.weekRecord = this.buildWeekRecord()
    this.monthRecord = this.buildMonthRecord()
    this.yearRecord = this.buildYearRecord()
  }

  buildWeekRecord(): BarItem[] {
    let weekRecord: BarItem[] = []
    for (let i = 0; i < 7; i++) {
      let nextDate: string = this.weekdayList[i]
      let date: string = this.formatDateToWeekDay(nextDate)
      let record: ExerciseRecord = AppStorageV2.connect(ExerciseRecord, nextDate, () => new ExerciseRecord())!
      if (record.duration !== 0) {
        this.weekDays++
        this.weekDuration += record.duration
        this.weekEnergy += record.energy
        weekRecord.push({ date: date, value: record.duration })
      } else {
        weekRecord.push({ date: date, value: record.duration })
      }
    }
    return weekRecord
  }

  buildMonthRecord(): BarItem[] {
    let monthRecord: BarItem[] = []
    for (let i = 0; i < this.monthDayList.length; i++) {
      let date: string = this.monthDayList[i]
      let record: ExerciseRecord = AppStorageV2.connect(ExerciseRecord, date, () => new ExerciseRecord())!
      if (record.duration !== 0) {
        this.monthDays++
        this.monthDuration += record.duration
        this.monthEnergy += record.energy
        monthRecord.push({ date: date, value: record.duration })
      }
    }
    return monthRecord
  }

  buildYearRecord(): BarItem[] {
    let yearRecord: BarItem[] = []
    for (let i = 0; i < 12; i++) {
      let month: string = this.monthNames[i]
      const monthNum: number = i
      let record: Record = this.calculateMonthRecord(monthNum)
      if (record.duration !== 0) {
        this.yearDuration += record.duration
        this.yearEnergy += record.energy
        yearRecord.push({ date: month, value: record.duration })
      }
    }
    return yearRecord
  }

  calculateMonthRecord(monthNum: number): Record {
    let monthRecord: Record = { duration: 0, energy: 0 }
    const now = new Date();
    const year = now.getFullYear();
    // 获取当前月的第一天和最后一天
    const firstDay = new Date(year, monthNum, 1);
    const lastDay = new Date(year, monthNum + 1, 0); // 下个月的第0天就是当前月的最后一天
    // 生成当月所有日期
    let currentDate = new Date(firstDay);
    while (currentDate <= lastDay) {
      const dateStr = this.formatDate(currentDate);
      let record: ExerciseRecord = AppStorageV2.connect(ExerciseRecord, dateStr, () => new ExerciseRecord())!
      if (record.duration !== 0) {
        this.yearDays++
      }
      monthRecord.duration += record.duration
      monthRecord.energy += record.energy
      currentDate.setDate(currentDate.getDate() + 1);
    }
    return monthRecord
  }

  extractYearMonth(dateString: string): string {
    return dateString.substring(0, 7); // 取前7个字符 "YYYY-MM"
  }

  // 获取月份名称
  getMonthName(monthStr: string): string {
    const month = parseInt(monthStr.split('-')[1]);
    return this.monthNames[month - 1];
  }

  buildDateList(): string[] {
    let weekdayList: string[] = [];
    const today = new Date();
    const dayOfWeek = today.getDay();
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    const monday = new Date(today);
    monday.setDate(today.getDate() - daysToMonday);
    for (let i = 0; i < 7; i++) {
      const nextDate = new Date(monday);
      nextDate.setDate(monday.getDate() + i);
      const year = nextDate.getFullYear();
      const month = (nextDate.getMonth() + 1).toString();
      const day = nextDate.getDate().toString();
      if (i === 0 || i === 6) {
        this.showWeekDates.push(String(`${month}月${day}日`))
      }
      weekdayList.push(String(`${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`));
    }
    return weekdayList;
  }

  buildMonthList(): string[] {
    const dates: string[] = [];
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth(); // 注意：月份从0开始
    // 获取当前月的第一天和最后一天
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0); // 下个月的第0天就是当前月的最后一天
    // 生成当月所有日期
    let currentDate = new Date(firstDay);
    while (currentDate <= lastDay) {
      const dateStr = this.formatDate(currentDate);
      dates.push(dateStr);
      currentDate.setDate(currentDate.getDate() + 1);
    }
    return dates;
  }

  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  formatDateToWeekDay(dateString: string): string {
    const date = new Date(dateString);
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekDays[date.getDay()];
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '运动记录'
        })

        Column() {
          VCard() {
            Row({ space: 10 }) {
              TabSegmentButtonV2({
                items: this.textItems,
                selectedIndex: this.textSelectedIndex!!,
                itemSelectedBackgroundColor: ColorMetrics.resourceColor($r('app.color.app_theme')),
                itemSelectedFontColor: ColorMetrics.resourceColor($r('sys.color.font_on_primary')),
              })
            }
          }

          if (this.textSelectedIndex === 0) {
            this.WeeklyChart()  // 周统计组件
          } else if (this.textSelectedIndex === 1) {
            this.MonthlyChart() // 月统计组件
          } else {
            this.YearlyChart()  // 年统计组件
          }
        }
        .width('90%')
        .height(504)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding(12)
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.mine_background'))
    }
    .hideTitleBar(true)
  }

  @Builder
  DailyChart() {
    Column() {
      Row() {
        Image($r('app.media.ic_chart_left'))
          .width(24)
          .height(24)
        Text('8月13日')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
        Image($r('app.media.ic_chart_right'))
          .width(24)
          .height(24)
      }
      .width('90%')
      .height(24)
      .margin({ top: 16, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text('50')
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总时长 （分钟）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(152)
        .height(48)

        Column() {
          Text('12')
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总消耗 （千卡）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(152)
        .height(48)
      }
      .width(304)
      .height(48)
      .margin({ bottom: 16 })

      DayBarChart({
        chartData: {
          time: '2025-08-13',
          data: MOCK_BAR_CHART_LIST,
          typeLabel: '运动记录',
        },
      });
    }
  }

  @Builder
  WeeklyChart() {
    Column() {
      Row() {
        Image($r('app.media.ic_chart_left'))
          .width(24)
          .height(24)
        Text(`${this.showWeekDates[0]} - ${this.showWeekDates[1]}`)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
        Image($r('app.media.ic_chart_right'))
          .width(24)
          .height(24)
      }
      .height(24)
      .width(304)
      .margin({ top: 16, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text(String(this.weekDuration))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总时长 （分钟）')
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .width(101.3)
        .height(48)

        Column() {
          Text(String(this.weekEnergy))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总消耗 （千卡）')
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .height(48)
        .width(101.3)

        Column() {
          Text(String(this.weekDays))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('累计训练 （天）')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .height(48)
        .width(101.4)
      }
      .width(304)
      .height(48)
      .margin({ bottom: 16 })

      WeekBarChart({
        chartData: {
          weekday: `${String(new Date().getFullYear())}-${(new Date().getMonth() + 1).toString().padStart(2, '0')}`,
          data: this.weekRecord,
          typeLabel:'运动记录',
        },
      });
    }
  }

  @Builder
  YearlyChart() {
    Column() {
      Row() {
        Image($r('app.media.ic_chart_left'))
          .width(24)
          .height(24)
        Text(`${String(new Date().getFullYear())}年`)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
        Image($r('app.media.ic_chart_right'))
          .width(24)
          .height(24)
      }
      .width(304)
      .height(24)
      .margin({ top: 16, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text(String(this.yearDuration))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总时长 （分钟）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)

        Column() {
          Text(String(this.yearEnergy))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总消耗 （千卡）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)

        Column() {
          Text(String(this.yearDays))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('累计训练 （天）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)
      }
      .width(304)
      .height(48)
      .margin({ bottom: 16 })

      YearBarChart({
        chartData: {
          year: String(new Date().getFullYear()),
          data: this.yearRecord,
          typeLabel:'运动记录',
        },
      });
    }
  }

  @Builder
  MonthlyChart() {
    Column() {
      Row() {
        Image($r('app.media.ic_chart_left'))
          .width(24)
          .height(24)
        Text(`${String(new Date().getMonth() + 1)}月`)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
        Image($r('app.media.ic_chart_right'))
          .width(24)
          .height(24)
      }
      .width(304)
      .height(24)
      .margin({ top: 16, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          Text(String(this.monthDuration))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总时长 （分钟）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)

        Column() {
          Text(String(this.monthEnergy))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('总消耗 （千卡）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)

        Column() {
          Text(String(this.monthDays))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text('累计训练 （天）')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .width(101.3)
        .height(48)
      }
      .width(304)
      .height(48)
      .margin({ bottom: 16 })

      MonthBarChart({
        chartData: {
          month: `${String(new Date().getFullYear())}-${(new Date().getMonth() + 1).toString().padStart(2, '0')}`,
          data: this.monthRecord,
          typeLabel:'运动记录',
        },
      });
    }
  }
}

@Builder
function noop() {
}

@ComponentV2
export struct VCard {
  @Local
  title: ResourceStr = '';
  @BuilderParam
  content: () => void = noop;

  build() {
    Column({ space: 8 }) {
      if (this.title) {
        Text(this.title)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '100%' })
      }
      this.content()
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(8)
    .width('100%')
  }
}