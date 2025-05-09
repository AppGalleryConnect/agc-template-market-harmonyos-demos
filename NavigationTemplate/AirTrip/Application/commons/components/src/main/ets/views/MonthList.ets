import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, DataStorage, Day, DayInfo, TimeUtils } from 'common';

export class MonthData {
  year: number = 0
  month: number = 0
  yearMonthLabel: string = ''
  monthDays: Day[][] = []
}

/**
 * 月视图
 */
@ComponentV2
export struct MonthList {
  @Local list: MonthData[] = []
  // 设置应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  @Param currentSelectedDay: DayInfo =
    new DayInfo(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate(), '');
  // 日期点击回调
  @Event onDateClick: (day: DayInfo) => void = () => {
  };
  // 今天
  @Local today: Date = new Date()
  listScroller: ListScroller = new ListScroller()

  aboutToAppear() {
    // 根据当前年月，生成一年的年月
    for (let i = 0; i < 12; i++) {
      const month = (Constants.NOW_MONTH + i) % 12; // 处理跨年
      const year = Constants.TODAY_YEAR + Math.floor((Constants.NOW_MONTH + i) / 12); // 处理跨年
      const monthName: string = String(new Date(year, month).getMonth() + 1).padStart(2, '0')
      let yearMonth: string = `${year}年${monthName}月`

      let item: MonthData = new MonthData()
      item.year = year
      item.month = month
      item.yearMonthLabel = yearMonth
      item.monthDays = this.getMonthViewData(year, month + 1);

      this.list.push(item)
    }
  }

  /**
   * 获取指定月份数据
   */
  getMonthViewData(year: number, month: number) {
    return [...TimeUtils.byMonthDayForYear(year, month)];
  }

  isSelectedDay(day: DayInfo): boolean {
    let dayInfoStr: string = `${day.year}${day.month}${day.date}`
    let selectedDayStr: string =
      `${this.currentSelectedDay.year}${this.currentSelectedDay.month}${this.currentSelectedDay.date}`
    return dayInfoStr === selectedDayStr
  }

  getBackgroundColor(day: DayInfo): ResourceColor {
    if (this.isSelectedDay(day)) {
      return $r('sys.color.ohos_id_color_emphasize')
    }
    return Color.Transparent
  }

  getDayNumFontColor(day: DayInfo): ResourceColor {
    return this.disabled(day) ? '#ffdddbdb' : (this.isSelectedDay(day) ? $r('sys.color.white') : '#191919')
  }

  disabled(day: DayInfo): boolean {
    if (day.year > this.today.getFullYear()) {
      return false
    }
    if (day.year === this.today.getFullYear() && day.month > this.today.getMonth() + 1) {
      return false
    }
    if (day.year === this.today.getFullYear() && day.month === this.today.getMonth() + 1 &&
      day.date >= this.today.getDate()) {
      return false
    }
    return true
  }

  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(16)
      .backgroundColor($r('sys.color.white'))
      .width(Constants.FULL_PERCENT_WIDTH)
      .fontWeight(FontWeight.Bold)
      .padding({ left: 14, top: 12, bottom: 12 })
  }

  /**
   * 月视图一天的子组件
   * @param day 日期
   * @param idx 当前月份所在的下标
   */
  @Builder
  monthDayBuilder(day: Day, idx: number) {
    Column({space: 4}) {
      if (this.isSelectedDay(day.dayInfo)) {
        Text('去程')
          .fontSize(10)
          .fontColor(this.getDayNumFontColor(day.dayInfo))
      }
      Text(day.dayNum + '')
        .fontColor(this.getDayNumFontColor(day.dayInfo))
      //Text(day.lunarDay)
      //  .fontColor(this.getDayNumFontColor(day.dayInfo))
      //  .fontSize(10)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .height(Constants.FULL_PERCENT_HEIGHT)
    .borderRadius(8)
    .backgroundColor(this.getBackgroundColor(day.dayInfo))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .visibility(day.dayNum === 0 ? Visibility.Hidden : Visibility.Visible)
    .enabled(!this.disabled(day.dayInfo))
    .onClick(() => {
      this.dataStorage.selectCalendarListIndex = idx
      this.onDateClick && this.onDateClick(day.dayInfo)
    })
  }

  build() {
    Column() {
      List({ scroller: this.listScroller }) {
        ForEach(this.list, (item: MonthData, idx: number) => {
          ListItemGroup({ header: this.itemHead(item.yearMonthLabel) }) {
            ForEach(item.monthDays, (days: Day[]) => {
              ListItem() {
                Row() {
                  ForEach(days, (day: Day, index: number) => {
                    Column() {
                      this.monthDayBuilder(day, idx)
                    }
                    .height(52)
                    .width('calc((100% - 12vp) / 7)')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                  })
                }
                .width(Constants.FULL_PERCENT_WIDTH)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .padding(6)
            })
          }
        })
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .sticky(StickyStyle.Header)
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        if (newValue) {
          this.listScroller.scrollToItemInGroup(this.dataStorage.selectCalendarListIndex, 0, true)
        }
      })
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .height(Constants.FULL_PERCENT_HEIGHT)
  }
}