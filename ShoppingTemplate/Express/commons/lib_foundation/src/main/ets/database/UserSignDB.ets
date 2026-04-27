import { relationalStore } from '@kit.ArkData';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { UserSign } from '../model/UserSign';
import { IUserSignRequest } from '../model/IRequest';

const TAG = '[UserSignDB]';
const TABLE_NAME = 'user_sign';

// 用户签到表
class UserSignDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        week_start_time INTEGER NOT NULL,
        sign_mask INTEGER DEFAULT 0,
        last_sign_time INTEGER,
        FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE
      )`,
    indexes: [
      `CREATE INDEX IF NOT EXISTS idx_user_week ON ${TABLE_NAME} (user_id, week_start_time)`
    ]
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema);
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 获取用户本周签到数据
  async getWeeklyData(userId: number, monday: number) {
    // 条件1
    const condition1 = {
      field: 'user_id',
      value: userId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    // 条件2
    const condition2 = {
      field: 'week_start_time',
      value: monday,
      operator: DBOperator.EQUAL
    } as TablePredicate;

    let resultSet = await rdbHelper.query(TABLE_NAME, [condition1, condition2]);
    if (!resultSet) {
      return new UserSign();
    }
    try {
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        return UserSign.fromResultSet(resultSet);
      } else {
        // 本周尚无记录，初始化一条
        const bucket: relationalStore.ValuesBucket = {
          'user_id': userId,
          'week_start_time': monday,
          'sign_mask': 0
        };
        await rdbHelper.insert(TABLE_NAME, bucket);
        return new UserSign();
      }
    } catch (error) {
      Logger.error(TAG, `getWeeklyData failed. error: ${JSON.stringify(error)}`)
    }
    return new UserSign();
  }

  // 执行签到：同步更新积分和掩码
  async doSign(param: IUserSignRequest) {
    const data = await this.getWeeklyData(param.userId, param.monday);
    const newMask = data.signMask | (1 << param.dayIndex);

    return rdbHelper.runTransaction(async () => {
      // 条件1
      const condition1 = {
        field: 'user_id',
        value: param.userId,
        operator: DBOperator.EQUAL
      } as TablePredicate;
      // 条件2
      const condition2 = {
        field: 'week_start_time',
        value: param.monday,
        operator: DBOperator.EQUAL
      } as TablePredicate;

      const signBucket: relationalStore.ValuesBucket = {
        'sign_mask': newMask,
        'last_sign_time': Date.now()
      };
      await rdbHelper.update(TABLE_NAME, signBucket, [condition1, condition2]);

      // 2. 更新用户总积分
      const sql = 'UPDATE user SET points = points + ? WHERE user_id = ?'
      await rdbHelper.executeSql(sql, [param.points, param.userId]);

      // 3. 插入积分明细
      const detailBucket: relationalStore.ValuesBucket = {
        'user_id': param.userId,
        'amount': param.points,
        'description': '每日签到奖励',
        'create_time': Date.now(),
      };
      await rdbHelper.insert('point_detail', detailBucket);
      return 1;
    });
  }
}

const userSignDB = new UserSignDB();

export { userSignDB as UserSignDB };