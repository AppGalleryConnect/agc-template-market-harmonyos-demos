import { Context } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';

export class GlobalContext {
  private constructor() {
  }

  private static instance: GlobalContext;
  private context: Context | undefined
  private calendarMgr: calendarManager.CalendarManager | null = null;
  public static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  setContext(context: Context) {
    this.context = context
  }

  getContext(): Context | undefined {
    return this.context
  }

  getCalendarMgr():calendarManager.CalendarManager | null {
    return this.calendarMgr
  }
  setCalendarMgr(calendarMgr:calendarManager.CalendarManager | null){
    this.calendarMgr = calendarMgr
  }
}