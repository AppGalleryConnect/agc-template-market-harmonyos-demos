import { BusinessError } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { CalendarResult, GlobalContext, InstitutionsItem } from 'common';

export async function calendarEventAdd(institutionsItem: InstitutionsItem, calendarStartTime: number,
  calendarEndTime: number): Promise<CalendarResult> {
  let calendarMgr: calendarManager.CalendarManager | null = GlobalContext.getInstance().getCalendarMgr()
  let calendar: calendarManager.Calendar | undefined = undefined;
  const event: calendarManager.Event = {
    title: institutionsItem.name,
    location: institutionsItem.location,
    type: calendarManager.EventType.NORMAL,
    startTime: calendarStartTime,
    endTime: calendarEndTime
  };
  calendar = await calendarMgr?.getCalendar()
  return new Promise((resolve, reject) => {
    calendar?.addEvent(event, (err: BusinessError, data: number) => {
      if (err) {
        console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
        reject('Failed')
      } else {
        console.info(`Succeeded in adding event, id -> ${data}`);
        /*
         * 保存日历id
         * */
        resolve({
          data: data,
          status: 'Succeeded'
        })
      }
    })
  })
}
