import { Lunar } from 'lunar';
import dayjs from 'dayjs';

@ObservedV2
export class AlmanacVM {
  private static _instance: AlmanacVM
  @Trace selectDate: Date = new Date()
  @Trace yiText: string[] = []
  @Trace jiText: string[] = []
  @Trace lunarDate: string = ''
  @Trace yinLiDate: string = ''
  /**
   * 五行
   */
  @Trace fiveElement: string[] = []
  /**
   * 冲煞
   */
  @Trace clashElements: string = ''
  /**
   * 彭祖白忌
   */
  @Trace pengZuBaiJi: string = ''
  /**
   * 吉神宜趋
   */
  @Trace jiShenYiQu: string[] = []
  /**
   * 凶神宜忌
   */
  @Trace xiongShenYiJi: string[] = []
  private cachedLunar: Lunar | null = null
  private cachedDateKey: string = ''

  public static get instance() {
    if (!AlmanacVM._instance) {
      AlmanacVM._instance = new AlmanacVM()
    }
    return AlmanacVM._instance
  }

  private getLunar(): Lunar {
    const key = this.selectDate.toDateString()
    if (this.cachedLunar && this.cachedDateKey === key) {
      return this.cachedLunar
    }
    this.cachedLunar = Lunar.fromDate(dayjs(this.selectDate).toDate())
    this.cachedDateKey = key
    return this.cachedLunar
  }

  @Monitor('selectDate')
  selectDateChange() {
    this.cachedLunar = null
    this.cachedDateKey = ''
    const lunar = this.getLunar()
    this.yiText = lunar.getDayYi()
    this.jiText = lunar.getDayJi()
    this.lunarDate = `${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`
    this.clashElements = lunar.getDayChongDesc()
    this.fiveElement = lunar.getBaZiWuXing()
    this.pengZuBaiJi = lunar.getPengZuGan() + lunar.getPengZuZhi()
    this.jiShenYiQu = lunar.getDayJiShen()
    this.xiongShenYiJi = lunar.getDayXiongSha()
    const yearGanZhi = lunar.getYearInGanZhi()
    const shengXiao = lunar.getYearShengXiao()
    const monthGanZhi = lunar.getMonthInGanZhi()
    const dayGanZhi = lunar.getDayInGanZhi()
    this.yinLiDate = `${yearGanZhi}${shengXiao}年 ${monthGanZhi}月 ${dayGanZhi}日`
  }

  public setSelectDate(date: Date) {
    this.selectDate = date
  }
}