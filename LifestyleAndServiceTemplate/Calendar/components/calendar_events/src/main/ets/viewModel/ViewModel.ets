import { UserEvent, UserEventItem } from '../model/UserEventModel'
import { promptAction } from '@kit.ArkUI'
import { baseActionSheet, baseToast, ToastUtils } from 'base_apis'
import { CalendarManage } from '../utils/CalendarEvent'
import { common } from '@kit.AbilityKit'
import dayjs from 'dayjs'
import { compareDates } from '../utils/Utils'
import { eventTypeEnum, EVENT_TYPE } from '../constants/Constants'
import { RemindEventDispatcher } from '../utils/EventDispatcher'
import { RdbInit } from '../database/RdbInit'
import { UserEventDB } from '../database/UserEventDB'


@ObservedV2
export class CalendarEventVM {
  private static _instance: CalendarEventVM
  @Trace currentIndex: number = 0
  pageInfo: NavPathStack | null = null
  calendarManage: CalendarManage = CalendarManage.instance
  @Trace userEventInfo: UserEventItem = new UserEventItem()
  @Trace userEvent: UserEvent = new UserEvent()
  context: UIContext | undefined = undefined
  static get instance() {
    if (!CalendarEventVM._instance) {
      CalendarEventVM._instance = new CalendarEventVM()
    }
    return CalendarEventVM._instance
  }

  public async initDBAndLoad(context: Context) {
    const events = await RdbInit.loadAllEvents()
    this.userEvent.userEventList = events
  }

  public setEventInfo(eventInfo: UserEventItem) {
    this.userEventInfo.id = eventInfo.id
    this.userEventInfo.eventType = eventInfo.eventType
    this.userEventInfo.content = eventInfo.content
    eventInfo.date.forEach((value, index) => {
      this.userEventInfo.date[index].date = value.date
      this.userEventInfo.date[index].time = value.time
      this.userEventInfo.date[index].isLunar = value.isLunar
      this.userEventInfo.date[index].lunarDate = value.lunarDate
    })
    this.userEventInfo.repeatType = eventInfo.repeatType
    this.userEventInfo.remindList = [...eventInfo.remindList]
    this.userEventInfo.isDone = eventInfo.isDone
    this.userEventInfo.eventId = eventInfo.eventId
    this.userEventInfo.remarks = eventInfo.remarks
  }

  validateSchedule(userEventInfo: UserEventItem): boolean {
    let start = dayjs(userEventInfo.date[0].date).format('YYYY-MM-DD') + '  ' + userEventInfo.date[0].time
    let end = dayjs(userEventInfo.date[1].date).format('YYYY-MM-DD') + '  ' + userEventInfo.date[1].time
    return compareDates(new Date(start), new Date(end))
  }

  public async validate(userEventInfo: UserEventItem) {
    let tips: string = ''
    switch (CalendarEventVM.instance.currentIndex) {
      case 0:
        tips = '请输入日程内容'
        break
      case 1:
        tips = '请输入生日标题'
        break
      case 2:
        tips = '请输入纪念日标题'
        break
      case 3:
        tips = '请输入待办内容'
        break
    }
    if (!userEventInfo.content) {
      ToastUtils.showToast({ message: tips })
      return false
    }
    if (!this.validateSchedule(userEventInfo)) {
      ToastUtils.showToast({ message: '开始时间不能大于结束时间' })
      return false
    }
    return true
  }

  public setCurrentIndex(index: number) {
    this.currentIndex = index
  }

  public async updateUserEventInfo() {
    this.updateBirRemDate(this.userEventInfo)
    let validateRes: boolean = await CalendarEventVM.instance.validate(this.userEventInfo)
    if (!validateRes) {
      return false
    }
    await UserEventDB.updateEvent(this.userEventInfo)
    this.userEvent.userEventList.forEach(item => {
      if (item.id === this.userEventInfo.id) {
        item.content = this.userEventInfo.content
        this.userEventInfo.date.forEach((value, index) => {
          item.date[index].date = value.date
          item.date[index].time = value.time
          item.date[index].isLunar = value.isLunar
          item.date[index].lunarDate = value.lunarDate
        })
        item.repeatType = this.userEventInfo.repeatType
        item.eventType = this.userEventInfo.eventType
        item.remindList = [...this.userEventInfo.remindList]
        item.remarks = this.userEventInfo.remarks
        item.isDone = this.userEventInfo.isDone
      }
    })
    RemindEventDispatcher.dispatchToEventChange(this.userEventInfo)
    this.calendarManage.calendarEventCreate(this.userEventInfo)
    return true
  }


  public getEventLength(type: string) {
    let resLength = this.userEvent.userEventList.filter(item => item.eventType === type)
    return resLength.length
  }

  public async saveEventData(uiContext: UIContext, userEventInfo: UserEventItem) {
    userEventInfo.eventType = eventTypeEnum[this.currentIndex]
    this.updateBirRemDate(userEventInfo)
    let validateRes: boolean = await CalendarEventVM.instance.validate(userEventInfo)
    if (!validateRes) {
      return
    }
    this.calendarManage.calendarEventCreate(userEventInfo).then(async res => {
      if (res.status === 'success') {
        userEventInfo.eventId = userEventInfo.eventId ? userEventInfo.eventId : res.data as number
      }
    })
      .finally(async () => {
        await UserEventDB.insertEvent(userEventInfo)
        RemindEventDispatcher.dispatchToEventChange(userEventInfo)
        this.userEvent.userEventList.unshift(userEventInfo)
        baseActionSheet.close(uiContext, 'CalendarReminder')
      })
  }


  public deleteUserEventInfo(uiContext: UIContext, info: UserEventItem, cb?: () => void) {
    baseToast.show(uiContext, {
      type: 'dialog',
      cancelColor: $r('sys.color.font_primary'),
      confirmColor: '#E84026',
      message: '删除后将无法恢复，是否删除？',
      confirmMessage:'删除',
      confirmAction: async () => {
        RemindEventDispatcher.dispatchToEventDelete(this.userEventInfo)
        this.calendarManage.calendarEventCreate(info, 'delete')
        await UserEventDB.deleteEvent(info.id)
        let index = this.userEvent.userEventList.findIndex(item => item.id === info.id)
        this.userEvent.userEventList.splice(index, 1)
        if (cb) {
          cb()
        }
        baseToast.hide()
      },
    })
  }

  public setPageInfo(pageInfo: NavPathStack) {
    CalendarEventVM.instance.pageInfo = pageInfo
  }

  public getPageInfo() {
    return CalendarEventVM.instance.pageInfo
  }

  public setContext(context: UIContext) {
    CalendarEventVM.instance.context = context
    CalendarManage.instance.setContext(context)
  }

  public updateBirRemDate(userEventInfo: UserEventItem) {
    if (![EVENT_TYPE.SCHEDULE].includes(userEventInfo.eventType)) {
      if ([EVENT_TYPE.BIRTHDAY, EVENT_TYPE.ANNIVERSARIES].includes(userEventInfo.eventType)) {
        userEventInfo.date[0].time = `00:00`
      }
      userEventInfo.date[1].date = userEventInfo.date[0].date;
      userEventInfo.date[1].time = `23:59`
    }
  }

  public clearDate() {
    this.userEventInfo = new UserEventItem()
    this.currentIndex = 0
  }
}

export default CalendarEventVM