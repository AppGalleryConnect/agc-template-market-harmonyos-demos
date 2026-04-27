import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import dayjs from 'dayjs';
import { CalendarInfo, UserEventItem } from '../model/UserEventModel';
import { reminderMap, repeatMap } from '../constants/Constants';

export class CalendarManage {
  context?: common.UIAbilityContext;
  private static _instance: CalendarManage

  static get instance() {
    if (!CalendarManage._instance) {
      CalendarManage._instance = new CalendarManage()
    }
    return CalendarManage._instance
  }

  public getCalendarPermission(): Promise<string> {
    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    let atManager = abilityAccessCtrl.createAtManager();
    return new Promise((resolve, reject) => {
      atManager.requestPermissionsFromUser(this.context, permissions).then((result: PermissionRequestResult) => {
        resolve('success')
      }).catch((error: BusinessError) => {
        reject('failed')
        console.error(`get Permission error, error. Code: ${error.code}, message: ${error.message}`);
      })
    })
  }

  /*
    * 添加到日历
    * */
  private async calendarEvent(calendar: calendarManager.Calendar,
    calendarInfo: UserEventItem): Promise<CalendarInfo> {
    const event: calendarManager.Event = {
      title: calendarInfo.content,
      type: calendarManager.EventType.NORMAL,
      id: calendarInfo.eventId,
      isLunar:calendarInfo.date[0].isLunar,
      startTime: new Date(dayjs(calendarInfo.date[0].date).format('YYYY-MM-DD') + ' ' +
      calendarInfo.date[0].time).getTime(),
      endTime: new Date(dayjs(calendarInfo.date[1].date).format('YYYY-MM-DD') + ' ' +
      calendarInfo.date[1].time).getTime(),
      reminderTime: CalendarManage.getReminderTime(calendarInfo.remindList),
      recurrenceRule: {
        recurrenceFrequency: repeatMap[calendarInfo.repeatType],
      },
    };
    return new Promise(async (resolve, reject) => {
      if (calendarInfo.eventId) {
        calendar.updateEvent(event).then(() => {
          resolve({
            status: 'success',
          })
        }).catch((err: BusinessError) => {
          console.error(`Failed to update event. Code: ${err.code}, message: ${err.message}`);
        });
      } else {
        calendar.addEvent(event).then((data: number) => {
          console.info(`Succeeded in adding event, id -> ${data}`);
          resolve({
            status: 'success',
            data: data,
          })
        }).catch((err: BusinessError) => {
          resolve({
            status: 'failed',
          })
        });
      }
    })
  }

  public async calendarEventCreate(calendarInfo: UserEventItem, operationType?: string): Promise<CalendarInfo> {
    if (calendarInfo.remindList[0] === '不提醒') {
      return {
        status: 'not need calendar',
      }
    }
    let permission = await this.getCalendarPermission()
    if (permission !== 'success') {
      return {
        status: 'permission failed',
      }
    }
    let calendar: calendarManager.Calendar | undefined = undefined;
    // 指定日历账户信息
    const calendarAccount: calendarManager.CalendarAccount = {
      name: '日历模板',
      type: calendarManager.CalendarType.LOCAL,
      // 日历账户显示名称，该字段如果不填，创建的日历账户在界面显示为空字符串。
      displayName: '日历模板',
    };
    let calendarMgr: calendarManager.CalendarManager | null = calendarManager.getCalendarManager(this.context);
    // 创建日历账户
    try {
      calendar = await calendarMgr?.createCalendar(calendarAccount)
      let res: CalendarInfo
      if (operationType === 'delete') {
        res = await this.calendarEventDelete(calendar, calendarInfo)
      } else {
        res = await this.calendarEvent(calendar, calendarInfo)
      }
      return res
    } catch (e) {
      return {
        status: 'calendar operation failed',
      }
    }
  }

  private async calendarEventDelete(calendar: calendarManager.Calendar,
    calendarInfo: UserEventItem): Promise<CalendarInfo> {
    try {
      await calendar.deleteEvent(calendarInfo.eventId)
      return {
        status: 'success',
      }
    } catch (e) {
      return {
        status: 'failed',
      }
    }
  }

  public static getReminderTime(list: string[]) {
    let res: number[] = []
    list.forEach(item => res.push(reminderMap[item]))
    return res
  }

  public setContext(context: common.UIAbilityContext) {
    CalendarManage.instance.context = context
  }
}


