import dayjs from 'dayjs'
import { DateListSource } from '../models/CalendarDataSource'
import CalendarVM from './CalendarVM'

@ObservedV2
class DateListSourceVM {
  @Trace dateListSource: DateListSource = new DateListSource()
  @Trace curIndex: number = 1 // 当前swiper展示的index
  public monthStep: number = 0
  vm: CalendarVM = CalendarVM.instance
  private static _instance: DateListSourceVM

  public static get instance() {
    if (!DateListSourceVM._instance) {
      DateListSourceVM._instance = new DateListSourceVM()
    }
    return DateListSourceVM._instance
  }

  public initDateListSource() {
    let preMonth = this.vm.getDateList(-1)
    let curMonth = this.vm.getDateList(0)
    let nextMonth = this.vm.getDateList(1)
    this.dateListSource.pushData(preMonth)
    this.dateListSource.pushData(curMonth)
    this.dateListSource.pushData(nextMonth)
  }

  public handleSwiperChange(newIdx: number) {
    let curMonth = dayjs().month();
    // 向左
    if (newIdx < this.curIndex) {
      let newDate = this.vm.selectDate.add(-1, 'month')
        .startOf('month')
        .toDate()
      this.vm.changeDate(newDate)
      // 给source中添加数据
      if (newIdx === 0) {

      }
    } else if (newIdx > this.curIndex) {
      let newDate = this.vm.selectDate.add(1, 'month')
        .startOf('month')
        .toDate()
      this.vm.changeDate(newDate)
    }
  }
}

export default DateListSourceVM