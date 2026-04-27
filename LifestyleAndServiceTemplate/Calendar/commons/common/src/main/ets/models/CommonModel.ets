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
  @Trace calendarColor: string = ''
  @Trace titleColor: string = ''
  @Trace barColor: string = ''
  @Trace buttonColor: string = ''
  @Trace tabColor: string = ''
  @Trace tabColorInActive: string = ''
  @Trace textColor:string = ''
}


export class TabsInfo {
  icon: string = ''
  iconSel: string = ''
  name: string = ''
  id: string = ''
}

@ObservedV2
export class CalendarTool {
  id: string = ''
  icon?: string = ''
  name: string = ''
}



export class SolarToLunar {
  week: string = ''
  date: string = ''
}

@ObservedV2
export class TodayYiJi {
  @Trace yi: string [] = []
  @Trace ji: string[] = []
}


export class NavigationParams {
  navigationParams: ESObject

  constructor(navigationParams: ESObject) {
    this.navigationParams = navigationParams
  }
}