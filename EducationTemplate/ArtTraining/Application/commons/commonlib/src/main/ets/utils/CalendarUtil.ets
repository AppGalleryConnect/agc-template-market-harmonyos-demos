import { Permissions } from '@kit.AbilityKit';
import { PermissionUtil } from './PermissionUtil';
import { calendarManager } from '@kit.CalendarKit';
import { WindowUtil } from './WindowUtil';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

const TAG = '[CalendarUtil]';

export class CalendarUtil {
  public static async getCalendarMgr() {
    if (!canIUse('SystemCapability.Applications.CalendarData')) {
      promptAction.showToast({ message: '当前设备暂不支持日历服务' });
      return null;
    }
    const permissionArr: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    try {
      const res = await PermissionUtil.requestPermissions(permissionArr);
      if (res) {
        return calendarManager.getCalendarManager(WindowUtil.context);
      }
      return null;
    } catch (err) {
      Logger.error(TAG, 'get calendar manager failed:' + err);
      return null;
    }
  }

  public static async addEvent(title: string, date: Date) {
    const calendarMgr: calendarManager.CalendarManager | null = await CalendarUtil.getCalendarMgr();
    if (!calendarMgr) {
      Logger.warn('cannot get calendarMgr');
      return false;
    }
    const event: calendarManager.Event = {
      title, // 日程标题
      type: calendarManager.EventType.NORMAL,
      startTime: date.getTime(),
      endTime: date.getTime() + 60 * 60 * 1000,
      reminderTime: [30], // 距开始时间提前10分钟提醒
    };

    const calendar = await calendarMgr.getCalendar();
    return calendar.addEvent(event).then((data: number) => {
      Logger.info(TAG, `Succeeded in adding event, id -> ${data}`);
      return true;
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
      return false;
    });
  }
}