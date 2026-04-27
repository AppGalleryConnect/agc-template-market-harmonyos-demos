import { LineSchedule } from '../model/TourModel';
import { RandomUtil } from 'common'

export class CalendarUtil {
  /**
   * 生成日历价格数据
   * basePrice 当天的价格为基准作轻微波动（0 至 +150）,保证不低于最低价格10。
   * floatPrice: number,当天的价格为基准作轻微波动（如0 至 150），
   * days 包含今天在内，向后连续多少天。
   * allWeek 为false表示需要展示今天、明天、后天
   * date （星期）、 dateCode （MM-DD）、 price （¥价格）
   * @returns
   */
  static getCalendarPrice(basePrice: number, floatPrice: number, days: number, allWeek: boolean): LineSchedule[] {
    const today = new Date()
    const weekMap = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const pad2 = (n: number) => n < 10 ? `0${n}` : `${n}`
    const arr: LineSchedule[] = []
    for (let i = 0; i < days; i++) {
      const d = new Date(today.getFullYear(), today.getMonth(), today.getDate() + i)
      const dateCode = `${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
      // 是否需要显示今天,明天,后天
      let date = ''
      if (!allWeek && i <= 2) {
        date = i === 0 ? '今天' : i === 1 ? '明天' : '后天';
      } else {
        date = weekMap[d.getDay()]
      }
      // 价格围绕基础价做轻微波动
      const randomIndex = RandomUtil.getRandomIndex(floatPrice) // 生成0-floatPrice的随机数
      const fluctuation = Math.floor(basePrice) + randomIndex // 0-floatPrice之间浮动
      const priceNum = Math.max(basePrice, fluctuation)
      arr.push({ date, dateCode, price: priceNum,createDate:d })
    }
    return arr
  }
}