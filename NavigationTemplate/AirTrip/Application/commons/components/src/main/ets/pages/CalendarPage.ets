import { AppStorageV2 } from '@kit.ArkUI';
import { AppRouter, Constants, DataStorage, DayInfo } from 'common';
import { BaseTip } from '../components/BaseTip';
import { BaseTitle } from '../components/BaseTitle';
import { MonthList } from '../views/MonthList';

@Builder
export function calendarPageBuilder() {
  CalendarPage()
}


@ComponentV2
export struct CalendarPage {
  // 设置应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  // 当前月视图或周视图中选中的日期
  @Local currentSelectDay: DayInfo =
    new DayInfo(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate(), '');

  aboutToAppear(): void {
    if (this.dataStorage.departureDate) {
      this.currentSelectDay.year = this.dataStorage.departureDate.year
      this.currentSelectDay.month = this.dataStorage.departureDate.month
      this.currentSelectDay.date = this.dataStorage.departureDate.date
    }
  }

  /**
   * 星期
   */
  @Builder
  WeeksView() {
    Row() {
      ForEach(Constants.WEEKS, (text: string, index: number) => {
        Text(text)
          .fontColor((index === 0 || index === 6) ? $r('sys.color.white') : $r('sys.color.ohos_id_color_text_primary'))
          .textAlign(TextAlign.Center)
          .padding({left: 14, top: 6, right:14, bottom:6})
          .backgroundColor((index === 0 || index === 6) ? '#466DFA' : 'rgba(0,0,0,0.05)')
          .borderRadius(8)
      }, (text: string) => text)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .padding({left:16, right:16})
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 10 })
  }

  build() {
    NavDestination() {
      BaseTitle({
        title: '选择日期',
        showBackBtn: true,
        bgColor: $r('sys.color.white'),
        onBack: () => {
          AppRouter.pop()
        }
      })

      Column() {
        // 星期
        this.WeeksView()
        // 提示
        Row() {
          BaseTip({
            text: $r('app.string.calendar_tip'),
            icon: $r('app.media.ic_tip_horn')
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .padding({left: 16, top: 9, bottom:9})
        .backgroundColor('#F1F3F5')

        MonthList({
          currentSelectedDay: this.currentSelectDay,
          onDateClick: (day: DayInfo) => {
            this.currentSelectDay.year = day.year;
            this.currentSelectDay.month = day.month;
            this.currentSelectDay.date = day.date;
            this.currentSelectDay.weekDay = day.weekDay;

            this.dataStorage.departureDate = this.currentSelectDay
            AppRouter.pop()
          },
        })
          .layoutWeight(1)
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.white'))
    }
    .hideTitleBar(true)
  }
}