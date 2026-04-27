import { Type } from '@kit.ArkUI';
import { EVENT_TYPE } from '../constants/Constants';
import { generateId, solarToLunar } from '../utils/Utils';

@ObservedV2
export class LocalDate {
  @Trace localDateSelected: boolean = false
  @Trace localDateTimeSelected: boolean = false
  @Trace isLunar: boolean = false

  constructor(localDateSelected?: boolean, localDateTimeSelected?: boolean,
    isLunar?: boolean) {
    this.localDateSelected = localDateSelected ?? false
    this.localDateTimeSelected = localDateTimeSelected ?? false
    this.isLunar = isLunar ?? false
  }
}

@ObservedV2
export class CalendarChooseDate {
  @Trace localDate: Date = new Date()
  @Trace localDateTime: string = '09:00'
}


@ObservedV2
export class CalendarEvent {
  @Trace calendarEventList: LocalDate[] = [
    new LocalDate(false, false, true),
    new LocalDate(false, false, true),
  ]
}


@ObservedV2
export class CalendarStartDate {
  @Trace date: Date = new Date()
  @Trace lunarDate: string = solarToLunar(new Date())
  @Trace time: string = '09:00'
  @Trace isLunar: boolean = false
}

@ObservedV2
export class CalendarEndDate {
  @Trace date: Date = new Date(new Date().setDate(new Date().getDate() + 1))
  @Trace time: string = '09:00'
  @Trace lunarDate: string = solarToLunar(new Date(new Date().setDate(new Date().getDate() + 1)))
  @Trace isLunar: boolean = false
}

@ObservedV2
export class ReminderType {
  name: string = ''
  time: number = 0
  @Trace isSelected: boolean = false

  constructor(name: string, isSelected: boolean, time: number) {
    this.name = name
    this.isSelected = isSelected
    this.time = time
  }
}


@ObservedV2
export class ReminderForType {
  name: string = '正点提醒'
}

@ObservedV2
export class ReminderSheet {
  @Trace reminderSheet: ReminderType[] = [
    new ReminderType('不提醒', false, 0),
    new ReminderType('正点提醒', true, 60),
    new ReminderType('提前5分钟', false, 5),
    new ReminderType('提前15分钟', false, 15),
    new ReminderType('提前30分钟', false, 30),
    new ReminderType('提前1小时', false, 60),
    new ReminderType('提前1天', false, 1440),
    new ReminderType('提前2天', false, 2880),
    new ReminderType('提前3天', false, 4320),
  ]
}

export const reminderList: ReminderType[] = [
  new ReminderType('正点提醒', true, 60),
]

export class CalendarInfo {
  status: string = ''
  data?: number = 0
}

@ObservedV2
export class UserEventItem {
  id: string = generateId()
  eventType: EVENT_TYPE = EVENT_TYPE.SCHEDULE
  eventId: number = 0
  @Trace content: string = ''
  @Type(CalendarStartDate)
  @Trace date: CalendarStartDate[] = [
    new CalendarStartDate(), new CalendarEndDate(),
  ]
  @Trace repeatType: string = '不重复'
  @Trace remindList: string[] = ['正点提醒']
  @Trace remarks: string = ''
  @Trace isDone: boolean = false
}

@ObservedV2
export class CalendarEventMode {
  id: string = generateId()
  @Trace content: string = ''
  date: string = ''
  @Trace reminder: Date = new Date()
  @Trace remarks: string = ''
}

@ObservedV2
export class TodoDataGroup {
  title: string = ''
  @Type(UserEventItem)
  @Trace todoList: UserEventItem[] = []

  constructor(title: string, todoList: UserEventItem[]) {
    this.title = title
    this.todoList = todoList
  }
}

@ObservedV2
export class UserEvent {
  @Type(UserEventItem)
  @Trace userEventList: UserEventItem[] = [];
}


