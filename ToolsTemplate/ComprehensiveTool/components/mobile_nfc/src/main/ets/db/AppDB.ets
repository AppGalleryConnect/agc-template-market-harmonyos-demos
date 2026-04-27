import sql from '@liushengyi/smartdb';
import relationalStore from '@ohos.data.relationalStore';
import { nfcCardInfo } from './NfcCardInfo';

export class AppDB {
  static DB_VERSION: number = 1;

  initDb(context: Context) {
    sql.dbHelper.initDb(context, 'db_nfc.db', AppDB.DB_VERSION, new AppDbOpenHelper());
  }
}

class AppDbOpenHelper extends sql.DbOpenHelper {
  constructor() {
    super();
  }

  async onCreate(db: relationalStore.RdbStore) {
    try {
      await nfcCardInfo.createDb();
    } catch (e) {
      console.log('error ', JSON.stringify(e));
    }
  }

  async onUpgrade() {
  }
}

export const appDB = new AppDB();