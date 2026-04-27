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

export enum CALCULATION_TYPE  {
  FORWARD = 'forward',
  BACKWARD = 'backward'
}