@ObservedV2
export class DateItem {
  date: string = ''
  status: string = '' // 1为放假，2为补班
}

@ObservedV2
export class HolidayMonthDetail {
  festival: string
  desc: string
  list: DateItem[]
  name: string

  constructor(httpData: ESObject) {
    this.festival = httpData.festival
    this.desc = httpData.desc
    this.list = httpData.list
    this.name = httpData.name
  }
}

export class HolidayItem {
  startday: string
  name: string

  constructor(startday: string, name: string) {
    this.startday = startday
    this.name = name
  }
}

export class HolidayDetail {
  animalsYear: string
  avoid: string
  date: string
  desc: string
  holiday: string
  lunar: string
  lunarYear: string
  suit: string
  weekday: string
  year: string
  month: string

  constructor(httpData: ESObject) {
    this.animalsYear = httpData.animalsYear
    this.avoid = httpData.avoid
    this.date = httpData.date
    this.desc = httpData.desc
    this.holiday = httpData.holiday
    this.lunar = httpData.lunar
    this.lunarYear = httpData.lunarYear
    this.suit = httpData.suit
    this.weekday = httpData.weekday
    this.year = httpData.yea
    this.month = httpData.month
  }
}