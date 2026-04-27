import { relationalStore } from '@kit.ArkData';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { IPointHistoryRequest, IUserPointRequest } from '../model/IRequest';
import { PointDetail } from '../model/PointDetail';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';

const TAG = '[PointDetailDB]';
const TABLE_NAME = 'point_detail';

// 积分表
class PointDetailDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      amount INTEGER NOT NULL,
      description TEXT NOT NULL,
      create_time INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE
    )`,
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema);
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 积分变动
  public changePoints(data: IUserPointRequest): Promise<number> {
    return rdbHelper.runTransaction(async () => {
      // 1. 更新用户总积分
      const sql = 'UPDATE user SET points = points + ? WHERE user_id = ?'
      await rdbHelper.executeSql(sql, [data.amount, data.userId]);
      // 2. 插入明细记录
      const bucket: relationalStore.ValuesBucket = {
        'user_id': data.userId,
        'amount': data.amount,
        'description': data.desc,
        'create_time': Date.now()
      };
      await rdbHelper.insert(TABLE_NAME, bucket);
      return 1;
    })
  }

  // 获取积分明细列表
  public async queryPointHistory(param: IPointHistoryRequest) {
    const condition1 = {
      field: 'user_id',
      value: param.userId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    // 条件2
    const condition2 = {
      field: 'create_time',
      value: param.startTime,
      operator: DBOperator.GREATER_OR_EQUAL
    } as TablePredicate;
    // 条件3
    const condition3 = {
      field: 'create_time',
      value: param.endTime,
      operator: DBOperator.LESS
    } as TablePredicate;
    // 条件4
    const condition4 = {
      field: 'create_time',
      operator: DBOperator.ORDER_BY_DESC
    } as TablePredicate;

    let resultSet = await rdbHelper.query(TABLE_NAME, [condition1, condition2, condition3, condition4]);
    if (!resultSet) {
      return [];
    }
    let pointsHistory: PointDetail[] = [];
    try {
      while (resultSet.goToNextRow()) {
        pointsHistory.push(PointDetail.fromResultSet(resultSet));
      }
    } catch (error) {
      Logger.error(TAG, `queryPointHistory failed. error: ${JSON.stringify(error)}`)
    }
    return pointsHistory;
  }
}

const pointDetailDB = new PointDetailDB();

export { pointDetailDB as PointDetailDB };