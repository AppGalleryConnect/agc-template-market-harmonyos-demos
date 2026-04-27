import { calendarManager } from '@kit.CalendarKit'

export const reminderMap: Record<string, number> = {
  '不提醒': -1,
  '正点提醒': 0,
  '提前5分钟': 5,
  '提前15分钟': 15,
  '提前30分钟': 30,
  '提前1小时': 60,
  '提前1天': 1440,
  '提前2天': 2880,
  '提前3天': 4320,
}

export const repeatMap: Record<string, number> = {
  '不重复': -1,
  '每天': calendarManager.RecurrenceFrequency.DAILY,
  '每周': calendarManager.RecurrenceFrequency.WEEKLY,
  '每月': calendarManager.RecurrenceFrequency.MONTHLY,
  '每年': calendarManager.RecurrenceFrequency.YEARLY,
}

export enum EVENT_TYPE {
  SCHEDULE = 'schedule',
  BIRTHDAY = 'birthday',
  ANNIVERSARIES = 'anniversaries',
  TODO = 'todo'
}

export const eventTypeEnum = [EVENT_TYPE.SCHEDULE, EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES, EVENT_TYPE.TODO]

export const routerMap: Record<string, string> = {
  'schedule': 'ScheduleDetails',
  'birthday': 'BirthdayRememberDetails',
  'anniversaries': 'BirthdayRememberDetails',
  'todo': 'TodoDetails',
}

export const eventRecord: Record<string, string> = {
  'schedule': 'app.media.ic_schedule',
  'birthday': 'app.media.ic_birthday',
  'anniversaries': 'app.media.ic_remember',
  'todo': 'app.media.ic_todo',
}

export enum REMIND_MENU {
  NO_REPEAT = '不重复',
  DAILY = '每天',
  WEEKLY = '每周',
  MONTHLY = '每月',
  YEARLY = '每年',
  HOLIDAY = '法定工作日',
}

export const reminderMenuList: string[] = [
  REMIND_MENU.NO_REPEAT, REMIND_MENU.DAILY, REMIND_MENU.WEEKLY, REMIND_MENU.MONTHLY, REMIND_MENU.YEARLY,
  REMIND_MENU.HOLIDAY,
]


export enum REMIND_TYPE {
  PUNCTUAL = '正点提醒',
  NOT_REMIND = '不提醒'
}