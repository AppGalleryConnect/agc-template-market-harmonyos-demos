import { relationalStore } from '@kit.ArkData';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { Coupon } from '../model/Coupon';

const TAG = '[UserCouponDB]';
const TABLE_NAME = 'user_coupon';

// 用户优惠券表
class UserCouponDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      coupon_id INTEGER NOT NULL UNIQUE,
      status INTEGER DEFAULT 0,
      receive_time INTEGER,
      FOREIGN KEY (user_id) REFERENCES user (user_id),
      FOREIGN KEY (coupon_id) REFERENCES coupon (id)
    )`,
    indexes: [
      `CREATE INDEX IF NOT EXISTS idx_user_coupon_user_id ON ${TABLE_NAME} (user_id)`
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

  // 初始化用户优惠券
  async initDefaultUserCoupons(userId: number) {
    try {
      const querySql = `SELECT * FROM coupon`;
      let resultSet = await rdbHelper.querySql(querySql, []);
      let coupons: Coupon[] = [];
      if (!resultSet) {
        Logger.info(TAG, 'No default coupons found to associate.');
        return;
      }
      while (resultSet.goToNextRow()) {
        coupons.push(Coupon.fromResultSet(resultSet));
      }
      resultSet.close();

      if (coupons.length === 0) {
        Logger.info(TAG, 'No default coupons found to associate.');
        return;
      }

      const now = Date.now();
      const valueRows = coupons.slice(0, 3).map((item, index: number) => {
        const values = [
          `${index + 1}`,
          `${userId}`,
          `${item.id}`,
          `${item.couponStatus}`,
          `${now}`
        ];
        return `(${values.join(', ')})`;
      })

      const insertSql = `INSERT OR IGNORE INTO user_coupon (
        id, user_id, coupon_id, status, receive_time
      ) VALUES ${valueRows}`;

      await rdbHelper.executeSql(insertSql);
      Logger.info(TAG, `Successfully associated ${coupons.length} coupons to user ${userId}`);
    } catch (err) {
      Logger.error(TAG, `initDefaultUserCoupons failed: ${JSON.stringify(err)}`);
    }
  }

  // 获取用户优惠券
  async queryUserCouponList(userId: number) {
    const sql = `SELECT c.*, uc.status AS user_coupon_status
      FROM coupon c
      INNER JOIN user_coupon uc ON c.id = uc.coupon_id
      WHERE uc.user_id = ?
    `;

    try {
      let resultSet = await rdbHelper.querySql(sql, userId);
      if (!resultSet || resultSet.rowCount <= 0) {
        Logger.info(TAG, 'No coupons found for user: ' + userId);
        return [];
      }
      const userCoupons: Coupon[] = [];
      while (resultSet.goToNextRow()) {
        const coupon = Coupon.fromResultSet(resultSet);
        const statusIdx = resultSet.getColumnIndex('user_coupon_status');
        if (statusIdx !== -1) {
          coupon.couponStatus = resultSet.getLong(statusIdx);
        }
        userCoupons.push(coupon);
      }
      resultSet.close();
      return userCoupons;
    } catch (err) {
      Logger.error(TAG, `queryUserCouponList failed. error: ${JSON.stringify(err)}`);
      return [];
    }
  }

  /**
   * 领取优惠券
   * @param userId 用户ID
   * @param couponId 优惠券模板ID
   */
  async claimCoupon(userId: number, couponId: number): Promise<boolean> {
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        'user_id': userId,
        'coupon_id': couponId,
        'status': 0, // 初始状态：待使用
        'receive_time': Date.now()
      };
      const rowId = await rdbHelper.insert(TABLE_NAME, valueBucket);
      return rowId > 0;
    } catch (err) {
      Logger.error(TAG, `领取失败: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 检查是否有未领取的会员专属优惠券
   */
  async hasUnclaimedMemberCoupons(userId: number): Promise<boolean> {
    const now = Date.now();
    // 查找：模板表里有“会员”限制，且在 user_coupon 关联表中没有该用户的记录
    const sql = `
      SELECT COUNT(*) as count
      FROM coupon c
      LEFT JOIN user_coupon uc ON c.id = uc.coupon_id AND uc.user_id = ?
      WHERE c.usage_restriction LIKE '%会员%'
        AND c.end_time > ?
        AND uc.id IS NULL
    `;

    try {
      const resultSet = await rdbHelper.querySql(sql, [userId, now]);
      if (!resultSet) {
        return false;
      }
      let hasUnclaimed = false;
      if (resultSet.goToNextRow()) {
        const count = resultSet.getLong(resultSet.getColumnIndex('count'));
        hasUnclaimed = count > 0;
      }
      resultSet.close();
      return hasUnclaimed;
    } catch (err) {
      return false;
    }
  }

  /**
   * 一键领取所有包含“会员”限制说明的专属优惠券
   * @param userId 用户ID
   * @returns Promise<number> 返回1表示成功，-1表示失败
   */
  async claimMemberBenefitCoupons(userId: number): Promise<number> {
    const now = Date.now();

    try {
      return await rdbHelper.runTransaction(async () => {
        const batchSql = `
          INSERT OR IGNORE INTO user_coupon (user_id, coupon_id, status, receive_time)
          SELECT
            ? as user_id,
            id as coupon_id,
            0 as status,
            ? as receive_time
          FROM coupon
          WHERE usage_restriction LIKE '%会员%'
            AND end_time > ?
        `;

        // userId (注入到每行)、 now (领取时间)、 now (用于过期时间比对)
        await rdbHelper.executeSql(batchSql, [userId, now, now]);
        Logger.info('UserCouponDB', `用户 ${userId} 批量领取会员券成功`);
        return 1;
      });
    } catch (err) {
      Logger.error('UserCouponDB', `批量领取失败: ${JSON.stringify(err)}`);
      return -1;
    }
  }

  /**
   * 使用优惠券
   * @param userId 用户ID
   * @param couponId 优惠券ID
   */
  async useCoupon(userId: number, couponId: number): Promise<boolean> {
    const condition1 = {
      field: 'user_id',
      value: userId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    const condition2 = {
      field: 'coupon_id',
      value: couponId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    const valueBucket: relationalStore.ValuesBucket = {
      'status': 1
    }
    const resp = await rdbHelper.update(TABLE_NAME, valueBucket, [condition1, condition2]);
    return resp > 0;
  }

  /**
   * 取消订单时还原优惠券状态
   * @param userId 用户ID
   * @param couponId 需要退还的优惠券ID
   */
  async refundCoupon(userId: number, couponId: number): Promise<boolean> {
    try {
      const refundSql = `UPDATE ${TABLE_NAME} SET status = 0
        WHERE coupon_id = ? AND user_id = ? AND status = 1`;
      await rdbHelper.executeSql(refundSql, [couponId, userId]);
      Logger.info(TAG, `优惠券 ${couponId} 已退还给用户 ${userId}`);
      return true;
    } catch (err) {
      Logger.error(TAG, `退还失败: ${JSON.stringify(err)}`);
      return false;
    }
  }
}

const userCouponDB = new UserCouponDB();

export { userCouponDB as UserCouponDB };