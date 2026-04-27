import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { MockData } from '../http/MockData';
import { Logistics } from '../model/Logistics';
import { relationalStore } from '@kit.ArkData';

const TAG = '[LogisticsDB]';
const TABLE_NAME = 'logistics';

// 物流轨迹表
class LogisticsDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcel_number TEXT NOT NULL,
        occurrence_time INTEGER NOT NULL,
        description TEXT NOT NULL,
        location TEXT,
        node_status INTEGER,
        operator_name TEXT,
        operator_phone TEXT,
        FOREIGN KEY (parcel_number) REFERENCES parcel (parcel_number) ON DELETE CASCADE
      )`,
    indexes: [
      `CREATE INDEX IF NOT EXISTS idx_logistics_pno ON ${TABLE_NAME} (parcel_number)`,
      `CREATE INDEX IF NOT EXISTS index_occurrence_time ON ${TABLE_NAME} (occurrence_time)`
    ]
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema).then(() => {
        // 数据库创建成功之后插入默认数据
        this.initLogisticsData();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  async initLogisticsData() {
    const valueRows = MockData.LOGISTICS_MOCK_LIST.map((item) => {
      // 简单的字符串转义函数，防止描述中的特殊字符破坏SQL结构
      const esc = (val: string) => val ? val.replace(/'/g, `''`) : '';
      return `(
        ${item.id},
        '${esc(item.parcelNumber)}',
        ${item.occurrenceTime},
        '${esc(item.description)}',
        '${esc(item.location)}',
        ${item.nodeStatus},
        '${esc(item.operatorName)}',
        '${esc(item.operatorPhone)}'
      )`;
    }).join(', ');
    const sql = `INSERT OR IGNORE INTO ${TABLE_NAME} (
      id, parcel_number, occurrence_time, description,
      location, node_status, operator_name, operator_phone
    ) VALUES ${valueRows}`;
    try {
      await rdbHelper.executeSql(sql);
    } catch (err) {
      Logger.error('LogisticsDB', `init Logistics failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 创建物流轨迹
  public async createLogistics(logistics: Logistics): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = {
      'parcel_number': logistics.parcelNumber,
      'occurrence_time': logistics.occurrenceTime,
      'description': logistics.description,
      'location': logistics.location,
      'node_status': logistics.nodeStatus,
    };
    if (logistics.operatorName) {
      valueBucket.operator_name = logistics.operatorName;
    }
    if (logistics.operatorPhone) {
      valueBucket.operator_phone = logistics.operatorPhone;
    }
    // 插入并获取生成的自增 ID
    const rowId = await rdbHelper.insert(TABLE_NAME, valueBucket);
    return rowId;
  }

  // 查询当前运单的物流轨迹的个数
  public async queryLogisticsCountByNumber(parcelNo: string) {
    // 条件
    const condition = {
      field: 'parcel_number',
      value: parcelNo,
      operator: DBOperator.EQUAL
    } as TablePredicate;

    let resultSet = await rdbHelper.query(TABLE_NAME, [condition]);
    // 直接通过 rowCount 属性获取结果集的行数
    if (!resultSet) {
      return 0;
    }
    const count = resultSet.rowCount;
    try {
      // 记得关闭结果集释放内存
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `resultSet close failed. error: ${JSON.stringify(error)}`);
    }

    return count >= 0 ? count : 0;
  }
}

const logisticsDB = new LogisticsDB();

export { logisticsDB as LogisticsDB };