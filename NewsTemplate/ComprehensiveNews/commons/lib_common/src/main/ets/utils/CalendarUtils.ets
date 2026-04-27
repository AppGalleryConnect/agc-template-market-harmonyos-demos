import { Permissions } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import { PermissionUtils } from './PermissionUtils';
import { Logger } from '../utils/Logger';

const TAG = '[CalendarUtils]';

export class CalendarUtils {
  private calendarMgr: calendarManager.CalendarManager | null = null;
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  /**
   * 获取CalendarManager
   * @param context
   * @returns
   */
  private async getCalendarManager(): Promise<calendarManager.CalendarManager | null> {
    if (this.calendarMgr) {
      return this.calendarMgr;
    }
    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    const isGranted = await PermissionUtils.requestPermissions(permissions);
    if (isGranted) {
      return calendarManager.getCalendarManager(this.context);
    }
    return null;
  }

  /**
   * 添加日程到日历
   * @param title 标题
   * @param startTime 开始时间（毫秒时间戳）
   * @param endTime 结束时间（毫秒时间戳）
   * @param reminderTime 提醒时间（单位分钟）
   * @returns eventId 日程的id
   */
  public async addEventToCalendar(title: string, startTime: number, endTime: number,
    reminderTime?: number): Promise<number> {
    try {
      this.calendarMgr = await this.getCalendarManager();
      if (!this.calendarMgr) {
        return 0;
      }
      const calendar = await this.calendarMgr.getCalendar();
      return calendar.addEvent({
        type: calendarManager.EventType.NORMAL,
        title: title,
        startTime: startTime,
        endTime: endTime,
        reminderTime: [reminderTime ?? 5],
      });
    } catch (e) {
      Logger.error(TAG, 'addEventToCalendar failed: ' + JSON.stringify(e));
      return 0;
    }
  }

  /**
   * 从日历移除日程
   * @param eventId 日程的id
   */
  public async removeEventsFromCalendar(eventIds: number[]): Promise<void> {
    try {
      this.calendarMgr = await this.getCalendarManager();
      if (!this.calendarMgr) {
        return;
      }
      const calendar = await this.calendarMgr.getCalendar();
      calendar.deleteEvents(eventIds).then(() => {
        Logger.info(TAG, 'Success to deleteEvents: ' + eventIds);
      });
    } catch (e) {
      Logger.error(TAG, 'removeEventFromCalendar failed: ' + JSON.stringify(e));
    }
  }
}