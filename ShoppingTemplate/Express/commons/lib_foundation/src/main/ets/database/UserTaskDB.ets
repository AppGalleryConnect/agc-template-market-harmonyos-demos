import { TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';

const TAG = '[UserTaskDB]';
const TABLE_NAME = 'user_task';

// 用户日常任务表
class UserTaskDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      task_id INTEGER NOT NULL,
      current_count INTEGER DEFAULT 0,
      is_finished INTEGER DEFAULT 0,
      is_received INTEGER DEFAULT 0,
      last_update_time INTEGER,
      UNIQUE(user_id, task_id)
    )`,
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema)
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }
}

const userTaskDB = new UserTaskDB();

export { userTaskDB as UserTaskDB };