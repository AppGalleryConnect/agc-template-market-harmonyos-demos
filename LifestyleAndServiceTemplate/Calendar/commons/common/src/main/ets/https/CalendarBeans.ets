export interface OldAlmanac {
  yi: string
  yinli: string
  wuxing: string
  jishen: string
  yangli: string
  baiji: string
  chongsha: string
  xiongshen: string
  ji: string
}

export interface DailyInfo {
  date?: string
  weekday?: string
  animalsYear?: string
  suit?: string
  avoid?: string
  holiday?: string
  lunar?: string
  lunarYear?: string
  desc?: string
}

export interface HolidaysMonth {
  year?: string
  holidayArray?: HolidaysMonthArray[]
  yearMonth: string
}

export interface HolidaysMonthArray {
  rest: string
  festival: string
  name: string
  list: HolidaysMonthArrayList[]
  desc: string
  listNum: number
}

export interface HolidaysMonthArrayList {
  date: string
  status: string
}

export interface HolidaysYear {
  year: string
  holidayList: HolidaysYearHolidayList[]
}

export interface HolidaysYearHolidayList {
  startday: string
  name?: string
}