export class FestivalList {
  name?: string = ''
  date: string = ''
  daysUntil: number = 0
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


export class SolarToLunar {
  week: string = ''
  date: string = ''
}

export class TodayYiJi {
  yi: string [] = []
  ji: string[] = []
}
