import { TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { MockCouponData } from '../http/MockCouponData';
import { ValueType } from '@kit.ArkData';
import { Coupon } from '../model/Coupon';

const TAG = '[CouponDB]';
const TABLE_NAME = 'coupon';

// 优惠券表
class CouponDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        usage_restriction TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        coupon_status INTEGER DEFAULT 0,
        discount_type INTEGER DEFAULT 0,
        full_amount REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        discount_coefficient REAL DEFAULT 0.0,
        created_time INTEGER NOT NULL
      )`,
    indexes: [`CREATE INDEX IF NOT EXISTS idx_coupon_status ON ${TABLE_NAME} (coupon_status)`],
  }

  // 创建表结构
  public async createTable() {
    try {
      rdbHelper.createTables(this.tableSchema).then(() => {
        // 数据库创建成功之后插入默认数据
        this.initDefaultCoupons();
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  async initDefaultCoupons() {
    const valueRows = MockCouponData.EXPRESS_COUPON_TEMPLATES.map((item) => {
      const escape = (str: ValueType) => String(str).replace(/'/g, `''`);
      const values = [
        item.id,
        `'${escape(item.name)}'`,
        `'${escape(item.usageRestriction)}'`,
        item.startTime,
        item.endTime,
        item.couponStatus,
        item.discountType,
        item.fullAmount,
        item.discountAmount,
        item.discountCoefficient,
        item.createdTime,
      ];
      return `(${values.join(', ')})`;
    }).join(', ');
    const sql = `INSERT OR IGNORE INTO ${TABLE_NAME} (
      id, name, usage_restriction, start_time, end_time,
      coupon_status, discount_type, full_amount,
      discount_amount, discount_coefficient, created_time
    ) VALUES ${valueRows}`;

    try {
      await rdbHelper.executeSql(sql);
    } catch (err) {
      Logger.error('CouponDB', `init coupons failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 获取福利页的优惠券
  async queryCouponList(userId: number) {
    // 获取当前时间戳
    const currentTime = Date.now();
    const sql = `SELECT c.*,
      uc.id AS received_id,
      uc.status AS user_actual_status
      FROM coupon c
      LEFT JOIN user_coupon uc ON c.id = uc.coupon_id AND uc.user_id = ?
      WHERE c.end_time > ?
      AND (uc.status IS NULL OR uc.status != 2)
      ORDER BY
        COALESCE(uc.receive_time, c.created_time) DESC,
        c.id ASC
    `;

    try {
      let resultSet = await rdbHelper.querySql(sql, [userId, currentTime]);
      if (!resultSet || resultSet.rowCount <= 0) {
        Logger.info('CouponDB', 'No coupons found for user: ' + userId);
        return [];
      }
      const coupons: Coupon[] = [];
      while (resultSet.goToNextRow()) {
        const coupon = Coupon.fromResultSet(resultSet);
        // 提取 received_id 用作 UI 判断
        const receivedIdIdx = resultSet.getColumnIndex('received_id');
        const receivedId = resultSet.getLong(receivedIdIdx);
        // 如果 receivedId > 0，说明 LEFT JOIN 匹配到了记录，即“已领取”
        coupon.receivedId = receivedId > 0 ? receivedId : undefined;
        // 如果已领取，用个人实际状态覆盖模板状态
        if (receivedId > 0) {
          const actualStatusIdx = resultSet.getColumnIndex('user_actual_status');
          coupon.couponStatus = resultSet.getLong(actualStatusIdx);
        }
        coupons.push(coupon);
      }
      resultSet.close();
      return coupons;
    } catch (err) {
      Logger.error('CouponDB', `queryCouponList failed. error: ${JSON.stringify(err)}`);
      return [];
    }
  }
}

const couponDB = new CouponDB();

export { couponDB as CouponDB };