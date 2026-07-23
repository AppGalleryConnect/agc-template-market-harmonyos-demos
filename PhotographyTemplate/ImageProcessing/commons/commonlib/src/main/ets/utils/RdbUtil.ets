import { RdbHelper } from '../database/RdbHelper';
import { UserDB } from '../database/UserDB';

export class RdbUtil {
  public static initDB(context: Context) {
    RdbHelper.initDB(context).then(() => {
      if (RdbHelper.getInstance().getStore()) {
        UserDB.createTable();
      }
    })
  }
}