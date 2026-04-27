import dayjs from 'dayjs'
import { Lunar } from 'lunar';
import { Constants } from '../constants/Constants';
import { DateListSource } from '../model/CalendarDataSource';
import { TodayYiJi } from '../model/CommonModel';
import { DateModel } from '../model/DateModel';
import { LunarModel } from '../model/LunarModel';

@ObservedV2
export class CalendarVM {
  @Trace selectDate: dayjs.Dayjs = dayjs()
  @Trace todayInfo: DateModel | null = null
  @Trace lunarInfo: LunarModel | null = null
  @Trace todayYiJi: TodayYiJi | null = null
  @Trace todayYinLi: string = ''
  @Trace festivalColor: ResourceStr | Color = ''
  @Trace dateListSource = new DateListSource()
  @Trace curIndex: number = 1
  @Trace weekStart: number = 1
  @Trace changeFlag: boolean = false
  @Trace monthDate: dayjs.Dayjs = dayjs()
  @Trace weekDayList: string[] = Constants.weekList
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
    if (!this.changeFlag) {
      if (newDate.year() === this.curDate.year() && newDate.month() === this.curDate.month()) {
        newDate = this.curDate
      } else {
        newDate = newDate.startOf('month')
      }
    } else {
      newDate = this.monthDate
    }
    this.changeFlag = false
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
  }

  public async getCurDateList() {
    this.selectDate = dayjs();
  }

  public isSwiperChange(item: DateModel, swiperController: SwiperController) {
    this.changeFlag = true
    if (!item.isToMonth) {
      if (new Date(item.dateStr) >= new Date(this.selectDate.format('YYYY-MM-DD'))) {
        swiperController.showNext()
      } else {
        swiperController.showPrevious()
      }
    }
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
    return this.selectDate.format('YYYY年MM月DD日')
  }

  public isDateSelect(item: DateModel) {
    return item.dayjsObj.format('YYYYMMDD') === this.selectDate.format('YYYYMMDD')
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
    console.log('changedate::' + this.selectDate.format('YYYYMMDD'))
  }

  public updateWeekdayStart(value: number) {
    this.weekStart = value
    this.dateListSource.clearArray()
    this.selectDate = dayjs()
    this.initDateListSource()
    this.changeWeekdayList()
  }

  public changeWeekdayList() {
    if (this.weekStart === 0 && this.weekDayList[0] !== '日') {
      const sunday = this.weekDayList.splice(6, 1)[0];
      this.weekDayList.unshift(sunday);
      return
    }
    if (this.weekStart === 1 && this.weekDayList[0] !== '一') {
      const sunday = this.weekDayList.shift();
      if (sunday !== undefined) {
        this.weekDayList.push(sunday);
      }
    }
  }

  public getDateList(param: number) {
    const baseDate = dayjs().add(param, 'month');

    // 计算当月首尾日期
    const firstDate = baseDate.startOf('month');
    const afterDate = baseDate.endOf('month');

    // 计算日历起始日（考虑周起始）
    const firstDateDay = firstDate.day();
    const weekStart = this.weekStart % 7;
    const frontPadding = (firstDateDay - weekStart + 7) % 7;
    const showFirstDay = firstDate.subtract(frontPadding, 'day');

    // 计算基础显示天数（包含前后缓冲）
    const baseDays = afterDate.diff(showFirstDay, 'day') + 1;

    // 计算需要的行数（向上取整）
    const rowsNeeded = Math.ceil(baseDays / 7);
    // 确保至少有5行
    const totalRows = Math.max(5, rowsNeeded);
    // 计算总单元格数
    const totalCells = totalRows * 7;

    // 生成日期数据
    let dateList: DateModel[] = [];
    for (let i = 0; i < totalCells; i++) {
      const dayjsObj = showFirstDay.add(i, 'day');

      // 智能月份判断（精确到月份）
      const isCurrentMonth = dayjsObj.isSame(firstDate, 'month');

      // 农历信息计算
      const lunarDate = Lunar.fromDate(dayjsObj.toDate());
      let lunarDay = this.getLunarInfo(lunarDate)[0];
      let lunarColor = this.getLunarInfo(lunarDate)[1];
      // 创建日期模型
      const dateModel = new DateModel(
        dayjsObj,
        dayjsObj.date(),
        lunarDay,
        isCurrentMonth,
        lunarColor,
        dayjsObj.format('YYYY-M-D')
      );

      // 记录当天信息
      if (dayjsObj.isSame(this.selectDate, 'day')) {
        this.todayInfo = dateModel;
      }

      dateList.push(dateModel);
    }

    return dateList;
  }
  private getLunarInfo(lunarDate: Lunar): [string, ResourceStr | Color] {
    if (lunarDate.getFestivals().length > 0) {
      return [lunarDate.getFestivals()[0], this.festivalColor];
    }
    if (lunarDate.getJieQi()) {
      return [lunarDate.getJieQi(), this.festivalColor];
    }
    const day = lunarDate.getDayInChinese();
    return day === '初一'
      ? [lunarDate.getMonthInChinese() + '月', this.festivalColor]
      : [day, $r('app.color.font_color_black')];
  }
}

export default CalendarVM