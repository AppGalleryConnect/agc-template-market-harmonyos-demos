import { Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { PermissionUtil } from './PermissionUtil';
import { WindowUtil } from './WindowUtil';

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
        return calendarManager.getCalendarManager(WindowUtil.globalContext);
      }
      return null;
    } catch (err) {
      Logger.error(TAG, 'get calendar manager failed:' + err);
      return null;
    }
  }

  public static async addEvent(event: calendarManager.Event) {
    const calendarMgr: calendarManager.CalendarManager | null = await CalendarUtil.getCalendarMgr();
    if (!calendarMgr) {
      return false;
    }

    try {
      const calendar = await calendarMgr.getCalendar();
      return calendar
        .addEvent(event)
        .then((data: number) => {
          Logger.info(TAG, `Succeeded in adding event, id -> ${data}`);
          return data;
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
          return false;
        });
    } catch (error) {
      Logger.error(TAG, `Failed to get calendar. error: ` + JSON.stringify(error));
      return false;
    }
  }
}
