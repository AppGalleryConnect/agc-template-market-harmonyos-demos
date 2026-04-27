import { RdbHelper } from '../database/RdbHelper';
import { UserDB } from '../database/UserDB';
import { AddressBookDB } from '../database/AddressBookDB';
import { GoodsDB } from '../database/GoodsDB';
import { TemplateDB } from '../database/TemplateDB';
import { ParcelDB } from '../database/ParcelDB';
import { UserSignDB } from '../database/UserSignDB';
import { PointDetailDB } from '../database/PointDetailDB';
import { LogisticsDB } from '../database/LogisticsDB';
import { CouponDB } from '../database/CouponDB';
import { UserCouponDB } from '../database/UserCouponDB';
import { TaskDB } from '../database/TaskDB';
import { UserTaskDB } from '../database/UserTaskDB';

export class RdbUtil {
  public static initDB(context: Context) {
    RdbHelper.initDB(context).then(() => {
      if (RdbHelper.getInstance().getStore()) {
        UserDB.createTable();
        AddressBookDB.createTable();
        GoodsDB.createTable();
        TemplateDB.createTable();
        ParcelDB.createTable();
        UserSignDB.createTable();
        PointDetailDB.createTable();
        LogisticsDB.createTable();
        CouponDB.createTable();
        UserCouponDB.createTable();
        TaskDB.createTable();
        UserTaskDB.createTable();
      }
    })
  }
}