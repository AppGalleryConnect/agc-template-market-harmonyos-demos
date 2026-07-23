import { UtilLog } from '@hw-agconnect/util-log';
import { RdbHelper } from './RdbHelper';
import { UserEventDB } from './UserEventDB';
import { UserEventItem } from '../model/UserEventModel';

const TAG = '[RdbInit]';
const DOMAIN = 0x0001;

export class RdbInit {
  private static initialized: boolean = false;

  public static async initDB(context: Context): Promise<boolean> {
    if (RdbInit.initialized) {
      return true;
    }
    try {
      const success = await RdbHelper.initDB(context);
      if (success) {
        await UserEventDB.createTable();
        RdbInit.initialized = true;
        UtilLog.info(DOMAIN, TAG, `CalendarEvent DB initialized success`);
      }
      return success;
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `initDB failed. error: ${JSON.stringify(err)}`);
      return false;
    }
  }

  public static async loadAllEvents(): Promise<UserEventItem[]> {
    return await UserEventDB.queryAllEvents();
  }

  public static async queryEventById(id: string): Promise<UserEventItem | undefined> {
    return await UserEventDB.queryEventById(id);
  }

  public static isInitialized(): boolean {
    return RdbInit.initialized;
  }
}
