import dayjs from 'dayjs'

export class DateModel {
  dayjsObj: dayjs.Dayjs // dayjs时间
  day: number // 天
  lunarDay: string // 农历
  lunarColor: Resource // 农历/节日、节气展示颜色
  isToMonth: boolean // 是否当前月
  dateStr: string // 日期字符串

  constructor(dayjsObj: dayjs.Dayjs, day: number, lunarDay: string, isToMonth: boolean, lunarColor: Resource,
    dateStr: string) {
    this.dayjsObj = dayjsObj
    this.day = day
    this.lunarDay = lunarDay
    this.isToMonth = isToMonth
    this.lunarColor = lunarColor
    this.dateStr = dateStr
  }
}

export class FestivalSolar {
  name: string = ''
  date: string = ''
  daysLeft: number = 0
}

export class FestivalEvents {
  name: string = ''
  getDate: ESObject = ''
}

export class DateModelList extends Array<DateModel> {
}