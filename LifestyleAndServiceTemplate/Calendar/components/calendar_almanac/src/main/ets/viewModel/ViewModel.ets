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

  public static get instance() {
    if (!AlmanacVM._instance) {
      AlmanacVM._instance = new AlmanacVM()
    }
    return AlmanacVM._instance
  }

  @Monitor('selectDate')
  selectDateChange() {
    this.getTodayYiJi()
    this.getLunarDay()
    this.getClashElementsInfo()
    this.getFiveElementsInfo()
    this.getPengZuBaiJi()
    this.getJiShenYiQu()
    this.getXiongShenYiJi()
    this.getTodayYinLi()
  }

  public getLunarDay() {
    const lunar = Lunar.fromDate(dayjs(this.selectDate).toDate());
    const lunarMonth = lunar.getMonthInChinese();
    const lunarDay = lunar.getDayInChinese()
    const lunarDate = `${lunarMonth}月${lunarDay}`;
    this.lunarDate = lunarDate
  }

  public getTodayYiJi() {
    const todayLunar = Lunar.fromDate(this.selectDate);
    // 获取今日宜和忌
    this.yiText = todayLunar.getDayYi();
    this.jiText = todayLunar.getDayJi();
  }

  public getClashElementsInfo() {
    const d = Lunar.fromDate(this.selectDate);
    this.clashElements = d.getDayChongDesc()
  }

  public getFiveElementsInfo() {
    const d = Lunar.fromDate(this.selectDate);
    this.fiveElement =  d.getBaZiWuXing()
  }

  public getPengZuBaiJi() {
    const d = Lunar.fromDate(this.selectDate);
    this.pengZuBaiJi =  d.getPengZuGan() + d.getPengZuZhi()
  }

  public getJiShenYiQu() {
    const d = Lunar.fromDate(this.selectDate);
    this.jiShenYiQu =  d.getDayJiShen()
  }

  public getXiongShenYiJi() {
    const d = Lunar.fromDate(this.selectDate);
    this.xiongShenYiJi = d.getDayXiongSha()
  }

  public getTodayYinLi() {
    const lunar = Lunar.fromDate(this.selectDate);
    const yearGanZhi = lunar.getYearInGanZhi(); // 获取天干地支年
    const shengXiao = lunar.getYearShengXiao(); // 获取生肖
    let monthGanZhi = lunar.getMonthInGanZhi(); // 获取月天干地支
    const dayGanZhi = lunar.getDayInGanZhi();
    this.yinLiDate =  `${yearGanZhi}${shengXiao}年 ${monthGanZhi}月 ${dayGanZhi}日`;
  }

  public setSelectDate(date: Date) {
    this.selectDate = date
  }
}