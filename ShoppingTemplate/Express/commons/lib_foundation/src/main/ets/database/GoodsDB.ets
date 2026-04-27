import { TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { defaultGoodsList, Goods } from '../model/Goods';

const TAG = '[GoodsDB]';
const TABLE_NAME = 'goods';

// 物品表
class GoodsDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        weight REAL DEFAULT 1.0,
        volume REAL
      )`,
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema).then(() => {
        // 数据库创建成功之后插入默认数据
        this.initDefaultGoods();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  async initDefaultGoods() {
    const valueRows = defaultGoodsList.map(item => `('${item.name}', ${item.weight}, ${item.volume})`).join(', ');
    const sql = `INSERT OR IGNORE INTO ${TABLE_NAME} (name, weight, volume) VALUES ${valueRows}`;
    try {
      await rdbHelper.executeSql(sql);
    } catch (err) {
      Logger.error('GoodsDB', `init goods failed. error: ${JSON.stringify(err)}`);
    }
  }

  public async queryGoodsList() {
    let resultSet = await rdbHelper.query(TABLE_NAME, []);
    if (!resultSet) {
      return [];
    }
    let goodsList: Goods[] = [];
    try {
      while (resultSet.goToNextRow()) {
        goodsList.push(Goods.fromResultSet(resultSet));
      }
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `queryGoodsList failed. error: ${JSON.stringify(error)}`)
    }
    return goodsList;
  }
}

const goodsDB = new GoodsDB();

export { goodsDB as GoodsDB };