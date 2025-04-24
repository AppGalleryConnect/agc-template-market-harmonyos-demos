import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { CommonConstants, GlobalRegister } from '@ohos_agcit/office_attendance_common_lib';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ScheduleInfo } from '../types/Types';

const TAG: string = 'ScheduleUtils';

export class ScheduleUtils {
  private static calendar: calendarManager.Calendar | undefined = undefined;

  public static initSysCalender() {
    if (ScheduleUtils.calendar) {
      return;
    }
    let calendarMgr: calendarManager.CalendarManager | null = null;
    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(GlobalRegister.getContext(), permissions)
      .then((result: PermissionRequestResult) => {
        calendarMgr = calendarManager.getCalendarManager(GlobalRegister.getContext());
        calendarMgr.getCalendar().then((data: calendarManager.Calendar) => {
          ScheduleUtils.calendar = data;
          console.info(`Succeeded in getting calendar, data -> ${JSON.stringify(data)}`);
        }).catch((err: BusinessError) => {
          hilog.info(0x0000, TAG, '%{public}s',
            `Failed to get calendar for Code: ${err.code}, message: ${err.message}`);
        });
      })
      .catch((error: BusinessError) => {
        hilog.info(0x0000, TAG, '%{public}s', 'get calendar permissions failed for ' + error.message);
      })

  }

  public static deleteEvent(eventId: number) {
    if (eventId) {
      ScheduleUtils.calendar?.deleteEvent(eventId).then(() => {
        console.info(`Succeeded in delete event(${eventId})`);
      }).catch((err: BusinessError) => {
        console.error(`Failed to delete event. Code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  public static updateEvent(schedule: ScheduleInfo) {
    if (schedule.id) {
      const updateEvent = ScheduleUtils.initEvent(schedule);
      updateEvent.id = schedule.eventId;
      ScheduleUtils.calendar?.updateEvent(updateEvent).then(() => {
        console.info(`Succeeded in updating event`);
      }).catch((err: BusinessError) => {
        console.error(`Failed to update event. Code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  public static async addEvent(schedule: ScheduleInfo): Promise<number | undefined> {
    const event = ScheduleUtils.initEvent(schedule);
    try {
      return await ScheduleUtils.calendar?.addEvent(event);
    } catch (e) {
      console.error(`Failed to update event. Code: ${e.code}, message: ${e.message}`);
      return new Promise<undefined>(() => undefined);
    }
  }

  private static initEvent(schedule: ScheduleInfo) {
    const event: calendarManager.Event = {
      // 日程标题
      title: schedule.title,
      description: schedule.desc,
      // 日程类型，不推荐三方开发者使用calendarManager.EventType.IMPORTANT，重要日程类型不支持一键服务跳转功能及无法自定义提醒时间
      type: calendarManager.EventType.NORMAL,
      isAllDay: schedule.isAllDay,
      // 日程开始时间
      startTime: new Date(schedule.startTime).getTime(),
      // 日程结束时间
      endTime: ScheduleUtils.getEndTime(schedule),
      // 距开始时间提前10分钟提醒
      reminderTime: schedule.reminderTime,
    }
    if (schedule.location) {
      event.location = { location: schedule.location, longitude: schedule.longitude, latitude: schedule.latitude }
    }
    if (schedule.recurrenceRule) {
      //维护的值比日历整体大2
      let recurrenceFrequency = schedule.recurrenceRule - 2;
      if (recurrenceFrequency) {
        // 日程重复规则，可选属性。如果日程为周期性日程需要填写该属性。
        event.recurrenceRule = { recurrenceFrequency: recurrenceFrequency }
      }
    }
    return event;
  }

  private static getEndTime(schedule: ScheduleInfo) {
    return schedule.isAllDay ? new Date(schedule.endTime).getTime() + CommonConstants.ONE_DAY :
    new Date(schedule.endTime).getTime();
  }
}