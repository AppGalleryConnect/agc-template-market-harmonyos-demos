import CalendarVM from '../viewModel/CalendarVM'

/**
 * 自定义表头数据
 */
export class CalendarHeaderItem {
  dateStr: string = ''
  day: string = ''
  lunarDay: string = ''
}

/**
 * 抛出句柄
 */
export class CalendarController {
  public static vm: CalendarVM = CalendarVM.instance;

  public setSelectDate(date: Date) {
    CalendarController.vm.changeDate(date)
  }

  public getTodayYiJi() {
    CalendarController.vm.getTodayYiJi()
  }
}