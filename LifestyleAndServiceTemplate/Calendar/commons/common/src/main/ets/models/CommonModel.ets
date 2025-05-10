export class FestivalList {
  name?: string = ''
  date: string = ''
  daysUntil: number = 0
}

@ObservedV2
export class SettingLevelItem {
  title: string = ''
  classifieds: SettingItem[] = []

  constructor(value: SettingLevelItem) {
    this.title = value.title
    value.classifieds.forEach(item => {
      this.classifieds.push(new SettingItem(item))
    })
  }
}

@ObservedV2
export class SettingItem {
  id: string = ''
  icon?: string = ''
  name: string = ''
  @Trace currentValue?: ResourceStr = ''

  constructor(item: SettingItem) {
    this.id = item.id
    this.icon = item.icon
    this.name = item.name
    this.currentValue = item.currentValue
  }
}

@ObservedV2
export class ThemeItem {
  id: string = ''
  name: string = ''
  @Trace color: string = ''
  @Trace titleColor: string = ''
  @Trace barColor: string = ''
  @Trace buttonColor: string = ''
  @Trace tabColor: string = ''
  @Trace tabColorInActive: string = ''
}


export class TabsInfo {
  icon: string = ''
  iconSel: string = ''
  title: string = ''
}

@ObservedV2
export class CalendarTool {
  id: string = ''
  icon?: string = ''
  name: string = ''
}

export class JiDayList {
  name: string = ''
  icon: string = ''
  list: string[] = []
}

export class LuckyDays {
  daysFromNow: number = 0
  solarDate: Date | string = ''
  lunarDate: string = ''
  ganZhiYear: string = ''
  ganZhiMonth: string = ''
  ganZhiDay: string = ''
  weekday: string = ''
}

export class SolarToLunar {
  week: string = ''
  date: string = ''
}

export interface ToggleItem {
  id: string
  name: string
}

export class TodayYiJi {
  yi:string [] = []
  ji:string[] = []
}
