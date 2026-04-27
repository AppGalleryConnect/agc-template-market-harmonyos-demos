export class LuckyDays {
  daysFromNow: number = 2
  solarDate: Date | string = '2025-05-10T00:00:00.000Z'
  lunarDate: string = '二〇二五年四月十三'
  ganZhiYear: string = '乙巳'
  ganZhiMonth: string = '辛巳'
  ganZhiDay: string = '己卯'
  weekday: string = '星期六'
  forwardOrBack?: CALCULATION_TYPE = CALCULATION_TYPE.FORWARD
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

export class CustomTabsInfo {
  icon: string = ''
  iconSel: string = ''
  name: string = ''
  id: string = ''
}