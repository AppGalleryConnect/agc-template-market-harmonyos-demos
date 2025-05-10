import dayjs from 'dayjs'
import { Lunar } from 'lunar';
import { DateModel } from '../models/DateModel'
import { DateListSource } from '../models/CalendarDataSource';
import { TodayYiJi } from '../models/CommonModel';
import { LunarModel } from '../models/LunarModel';
import { Https } from '../https/Https';
import { weekdayMap } from '../utils/CalculateDate';


@ObservedV2
export class CalendarVM {
  @Trace showSetting: boolean = true
  @Trace datePicker: Date = new Date()
  @Trace showDatePicker: boolean = false
  @Trace selectDate: dayjs.Dayjs = dayjs()
  @Trace lunarInfo: LunarModel | null = null
  @Trace todayYiJi: TodayYiJi | null = null
  @Trace dateListSource = new DateListSource()
  public monthStep: number = 0
  @Trace curIndex: number = 1 // 当前swiper展示的index
  private curDate: dayjs.Dayjs = dayjs()
  private static _instance: CalendarVM

  public static get instance() {
    if (!CalendarVM._instance) {
      CalendarVM._instance = new CalendarVM()
    }
    return CalendarVM._instance
  }

  public initDateListSource() {
    let i = -2
    while (i <= 2) {
      let month = this.getDateList(i)
      this.dateListSource.pushData(month)
      i++
    }
    this.curIndex = 2
  }

  public handleSwiper(newIndex: number, direction: number, controller: SwiperController) {
    console.log('index' + newIndex + '  ', this.curIndex)

    if (newIndex === 1 && this.curIndex === 0) {
      return;
    }
    let newDate = this.selectDate.add(direction, 'month')
    if (newDate.year() === this.curDate.year() && newDate.month() === this.curDate.month()) {
      newDate = this.curDate
    } else {
      newDate = newDate.startOf('month')
    }

    console.log(newIndex + direction + 'new date:::' + newDate.format('YYYYMMDD'))
    let gap = (newDate.year() - this.curDate.year()) * 12 + newDate.month() - this.curDate.month()
    if (newIndex === this.dateListSource.totalCount() - 1) {
      let newDateList = this.getDateList(gap + 1)
      this.dateListSource.addData(this.dateListSource.totalCount(), newDateList)
    } else if (newIndex === 0) {
      let newDateList = this.getDateList(gap - 1)
      this.dateListSource.addDataFromHead(newDateList)
      controller.changeIndex(1, false)
    }
    this.selectDate = dayjs(newDate)
    this.getCurLunarInfo()
    this.getTodayYiJi()
    console.log('changedate::' + this.selectDate.format('YYYYMDD'))
  }

  public async getCurDateList() {
    this.selectDate = dayjs();
    this.getCurLunarInfo()
    this.getTodayYiJi()
  }

  public getCurDate() {
    return this.selectDate.format('YYYY.MM.DD')
  }

  public async getCurLunarInfo() {
    await Https.getOldAlmanac({ date: this.selectDate.format('YYYY-MM-DD') }).then((resp) => {
      if (resp) {
        this.lunarInfo = new LunarModel(this.selectDate, resp)
      }
    })
  }

  public getTodayYiJi() {
    const todayLunar = Lunar.fromDate(new Date(this.selectDate.format('YYYY-MM-DD')));

    // 获取今日宜和忌
    const yi = todayLunar.getDayYi();
    const ji = todayLunar.getDayJi();
    this.todayYiJi = {
      yi,
      ji,
    }
  }

  public getDateLabel() {
    return this.selectDate.format('YYYY年MM月')
  }

  public getDateAllLabel() {
    return this.selectDate.format('YYYY-MM-DD')
  }

  public getCurSolarDate(date?: Date) {
    let currentDate = date ? dayjs(date).format('YYYY.MM.DD') : this.selectDate.format('YYYY.MM.DD')
    const lunar = Lunar.fromDate(new Date(currentDate));
    const lunarDate = lunar.toString()
    const weekday = weekdayMap[new Date().getDay()]
    return `${currentDate} ${weekday} ${lunarDate}`
  }

  public getLunarDateLabel() {
    let d = Lunar.fromDate(this.selectDate.toDate())
    return d.getMonthInChinese() + '月' + d.getDayInChinese()
  }

  public isDateSelect(item: DateModel) {
    return item.dayjsObj.format('YYYYMMDD') === this.selectDate.format('YYYYMMDD')
  }

  public getPreDate() {
    this.selectDate = this.selectDate.add(-1, 'day')
    this.getCurLunarInfo()
    this.getTodayYiJi()
  }

  public getNextDate() {
    this.selectDate = this.selectDate.add(1, 'day')
    this.getCurLunarInfo()
    this.getTodayYiJi()
  }

  public changeDate(date: Date) {
    let gap = (date.getFullYear() - this.curDate.year()) * 12 + date.getMonth() - this.curDate.month()
    console.log('new date::' + date.toDateString() + 'gap::' + gap)
    this.dateListSource.clearData()
    let i = -2
    while (i <= 2) {
      let month = this.getDateList(i + gap)
      this.dateListSource.pushData(month)
      i++
    }
    this.curIndex = 2
    this.selectDate = dayjs(date)
    this.getCurLunarInfo()
    this.getTodayYiJi()
    console.log('changedate::' + this.selectDate.format('YYYYMMDD'))
  }

  public getDateList(param: number) {
    let dateList: DateModel[] = []
    console.log(dayjs().add(param, 'month').toString())
    let firstDate = dayjs().add(param, 'month').startOf('month') // 当月的第一天
    let afterDate = dayjs().add(param, 'month').endOf('month') // 当月的最后一天
    let frontDay = 0 // 显示日历的第一天需要向前的天数
    if (firstDate.day() === 0) {
      frontDay = 6
    } else {
      frontDay = firstDate.day() - 1
    }
    let showFirstDay = firstDate.subtract(frontDay, 'day') // 显示日历的第一天
    for (let i = 0; i < 42; i++) {
      let dayjsObj = showFirstDay.add(i, 'day')
      let day = dayjsObj.date()
      let lunarDay = ''
      let lunarColor = $r('app.color.font_color_black')
      let lunarDate = Lunar.fromDate(dayjsObj.toDate())
      if (lunarDate.getFestivals().length !== 0) { // 显示节日
        lunarDay = lunarDate.getFestivals()[0]
        lunarColor = $r('sys.color.multi_color_04')
      } else if (lunarDate.getJieQi() !== '') { // 显示节气
        lunarDay = lunarDate.getJieQi()
        lunarColor = $r('sys.color.multi_color_04')
      } else { // 显示农历日期
        lunarDay = lunarDate.getDayInChinese()
        if (lunarDay === '初一') {
          lunarDay = lunarDate.getMonthInChinese() + '月'
          lunarColor = $r('sys.color.multi_color_04')
        }
      }
      let isToMonth = true
      if (dayjsObj.isBefore(firstDate) || dayjsObj.isAfter(afterDate)) {
        isToMonth = false
      }
      dateList.push(new DateModel(dayjsObj, day, lunarDay, isToMonth, lunarColor, dayjsObj.format('YYYY-M-D')))
    }
    return dateList;
  }
}

export default CalendarVM