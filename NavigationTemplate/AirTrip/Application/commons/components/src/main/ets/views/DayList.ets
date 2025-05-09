import { AppStorageV2 } from '@kit.ArkUI';
import { CommonDataSource, Constants, DataStorage, Day, DayInfo, TimeUtils } from 'common';

@ComponentV2
export struct DayList {
  // 设置应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!
  @Param currentSelectedDay: DayInfo =
    new DayInfo(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate(), '');
  // 日期点击回调
  @Event onDateClick: (day: DayInfo) => void = () => {
  };
  // 今天
  @Local today: Date = new Date()
  @Local dayList: DayInfo[] = []
  listScroller: ListScroller = new ListScroller()
  private listDataSource = new CommonDataSource<DayInfo>()
  @Local currentSelectDayIndex: number = 0

  aboutToAppear() {
    this.getAllDayList()
    this.currentSelectDayIndex = this.dayList.findIndex((item: DayInfo) => this.isSelectedDay(item))
  }

  @Monitor('currentSelectedDay.year', 'currentSelectedDay.month', 'currentSelectedDay.date')
  onChangeCurrentSelectedDay(monitor: IMonitor) {
    this.currentSelectDayIndex = this.dayList.findIndex((item: DayInfo) => this.isSelectedDay(item))
    this.scrollListToIndex(this.currentSelectDayIndex)
  }
  @Monitor('currentSelectedDay.currentDayFlightLowPrice')
  onChangeCurrentDayFlightLowPrice(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      let currentSelectDay = this.dayList.find((item: DayInfo) => this.isSelectedDay(item))
      let nowValue = monitor.value(path)?.now as number
      if (nowValue !== -1 && currentSelectDay) {
        currentSelectDay.currentDayFlightLowPrice = nowValue
      }
    })
  }

  /**
   * 获取以当前月份为起始月份，一年内的所有日期
   */
  getAllDayList() {
    let allDayList: Day[] = []
    // 根据当前年月，生成一年的年月
    for (let i = 0; i < 12; i++) {
      const month = (Constants.NOW_MONTH + i) % 12; // 处理跨年
      const year = Constants.TODAY_YEAR + Math.floor((Constants.NOW_MONTH + i) / 12); // 处理跨年
      let monthDays = this.getMonthViewData(year, month + 1)
      allDayList.push(...monthDays)
    }
    for (let i = 0; i < allDayList.length; i++) {
      const item = allDayList[i]
      if (item.dayNum && !this.disabled(item.dayInfo)) {
        this.dayList.push(item.dayInfo)
      }
    }
    this.listDataSource.setData(this.dayList)
  }

  /**
   * 获取指定月份数据
   */
  getMonthViewData(year: number, month: number) {
    let days: Day[][] = [...TimeUtils.byMonthDayForYear(year, month)]
    let daysByMonthList: Day[] = []
    for (let i = 0; i < days.length; i++) {
      const element = days[i]
      daysByMonthList.push(...element)
    }
    return daysByMonthList
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

  // 列表滚动到某个元素
  scrollListToIndex(index: number) {
    let scrollIndex = [0, 1].includes(index) ? index : index - 1
    this.listScroller.scrollToIndex(scrollIndex, true)
  }

  build() {
    Column() {
      List({ scroller: this.listScroller }) {
        LazyForEach(this.listDataSource, (item: DayInfo, idx: number) => {
          ListItem() {
            Column() {
              this.DayListItemBuilder(item, idx)
            }
            .height(Constants.FULL_PERCENT_HEIGHT)
            .width('calc((100% - 34vp) / 6)')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        })
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(64)
      .cachedCount(20)
      .padding({left: 16, bottom: 10})
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        if (newValue) {
          this.scrollListToIndex(this.currentSelectDayIndex)
        }
      })
    }
    .width(Constants.FULL_PERCENT_WIDTH)
  }

  /**
   * 月视图一天的子组件
   * @param day 日期
   * @param idx 当前月份所在的下标
   */
  @Builder
  DayListItemBuilder(day: DayInfo, idx: number) {
    Column({space: 3}) {
      Text(day.weekDay)
        .fontColor(this.getDayNumFontColor(day))
        .fontSize(8)
      Text(String(day.month).padStart(2, '0') + '.' + String(day.date).padStart(2, '0'))
        .fontColor(this.getDayNumFontColor(day))
        .fontSize(12)
      Text(day.currentDayFlightLowPrice === -1 ? '查看' : Constants.RMB + (day.currentDayFlightLowPrice || '--'))
       .fontColor(this.getDayNumFontColor(day))
       .fontSize(8)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .height(Constants.FULL_PERCENT_HEIGHT)
    .borderRadius(8)
    .backgroundColor(this.getBackgroundColor(day))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.scrollListToIndex(idx)
      this.onDateClick && this.onDateClick(day)
    })
  }
}