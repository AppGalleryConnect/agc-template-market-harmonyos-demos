export class JiDayList {
  name: string = ''
  icon: string = ''
  list: string[] = []
}
export enum CALCULATION_TYPE  {
  FORWARD = 'forward',
  BACKWARD = 'backward'
}

export class LunarInfo {
  year: string = ''
  month: string = ''
  day: string = ''
  weekday: string = ''
}

export class LuckyDays {
  daysFromNow: number = 0
  solarDate: Date | string = ''
  lunarDate: string = ''
  ganZhiYear: string = ''
  ganZhiMonth: string = ''
  ganZhiDay: string = ''
  weekday: string = ''
  forwardOrBack?: CALCULATION_TYPE = CALCULATION_TYPE.FORWARD
}

export class PickerDate {
  currentDate: string = ''
  weekday: string = ''
  lunarDate: string = ''
}