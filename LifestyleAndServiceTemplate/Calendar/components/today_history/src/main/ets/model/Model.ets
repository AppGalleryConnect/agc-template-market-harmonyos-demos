export class TodayHistoryData {
  day: string = ''
  date: string = ''
  title: string = ''
  description?: string = ''
}

export class HistoryParams {
  selectDate: Date = new Date()
  todayHistoryList: TodayHistoryData[] = []
  todayDayList: TodayHistoryData[] = []
}

export class TodayHistorySize extends TodayHistoryData {
  height: number = 0
}