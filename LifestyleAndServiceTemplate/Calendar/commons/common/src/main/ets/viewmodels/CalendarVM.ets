import { AppStorageV2 } from '@kit.ArkUI';
import dayjs from 'dayjs'
import { Lunar } from 'lunar';
import { BreakpointNameEnum, BreakpointType, GridRowColSetting } from '../constants/GridRowColSetting';
import { BreakpointModel } from '../models/BreakpointModel';
import { TodayYiJi } from '../models/CommonModel';
import { weekdayMap } from '../utils/CalculateDate';

@ObservedV2
export class CalendarVM {
  @Trace selectDate: dayjs.Dayjs = dayjs()
  @Trace todayYiJi: TodayYiJi = new TodayYiJi()
  @Trace todayYinLi: string = ''
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private lanes: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 2,
    xl: 2,
  });
  private static _instance: CalendarVM
  private cachedLunar: Lunar | null = null
  private cachedDateKey: string = ''

  private getLunar(date?: dayjs.Dayjs): Lunar {
    const d = date ?? this.selectDate
    const key = d.format('YYYY-MM-DD')
    if (this.cachedLunar && this.cachedDateKey === key) {
      return this.cachedLunar
    }
    this.cachedLunar = Lunar.fromDate(d.toDate())
    this.cachedDateKey = key
    return this.cachedLunar
  }

  public static get instance() {
    if (!CalendarVM._instance) {
      CalendarVM._instance = new CalendarVM()
    }
    return CalendarVM._instance
  }



  @Computed
  get pagePadding() {
    return GridRowColSetting.getPageMargin(this.breakPointModel.currentBreakpoint);
  }

  // 是否纵向Tab
  @Computed
  get isTabVertical() {
    return [
      BreakpointNameEnum.LG,
      BreakpointNameEnum.XL,
    ].includes(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get pagePaddingBottom() {
    if (this.isTabVertical) {
      return 28;
    }
    return 68;
  }

  public async getCurDateList() {
    this.selectDate = dayjs();
    this.getTodayYiJi()
  }

  public getCurDate() {
    return this.selectDate.format('YYYY.MM.DD')
  }

  public getTodayYiJi() {
    const todayLunar = this.getLunar();
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
    const lunar = date ? Lunar.fromDate(new Date(currentDate)) : this.getLunar()
    const lunarDate = lunar.toString()
    const weekday = weekdayMap[new Date().getDay()]
    return `${currentDate} ${weekday} ${lunarDate}`
  }

  public getLunarDateLabel() {
    const d = this.getLunar()
    return d.getMonthInChinese() + '月' + d.getDayInChinese()
  }

  /**
   * 节日节气栅格
   * */
  public getLanes(): number {
    return this.lanes.getValue(this.breakPointModel.currentBreakpoint)
  }
}

export default CalendarVM