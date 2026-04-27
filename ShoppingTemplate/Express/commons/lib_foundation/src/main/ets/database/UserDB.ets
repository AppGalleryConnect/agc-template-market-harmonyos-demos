import relationalStore from '@ohos.data.relationalStore';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { User } from '../model/User';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';

const TAG = '[UserDB]';
const TABLE_NAME = 'user';

// 用户信息表
class UserDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT NOT NULL UNIQUE,
        nickname TEXT,
        gender INTEGER DEFAULT 2,
        birthday TEXT,
        avatar TEXT,
        login_status INTEGER DEFAULT 0,
        last_login_time TEXT,
        is_real_name INTEGER DEFAULT 0,
        real_name TEXT,
        id_card_mask TEXT,
        is_vip INTEGER DEFAULT 0,
        vip_expire_time INTEGER DEFAULT 0,
        is_claim_benefit DEFAULT 0,
        points INTEGER DEFAULT 0
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

  // 用户登录  根据手机号判断用户是否已经存在
  public async userLogin(phone: string) {
    // 条件
    const condition = {
      field: 'phone',
      value: phone,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    // 当前时间戳
    const currentTime = Date.now().toString();
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await rdbHelper.query(TABLE_NAME, [condition]);

      // 1. 处理已存在用户
      if (resultSet && resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
        Logger.info(TAG, '用户已存在，执行登录状态更新');
        const valueBucket: relationalStore.ValuesBucket = {
          'login_status': 1,
          'last_login_time': currentTime,
        };
        await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
        const user = User.fromResultSet(resultSet);
        return user;
      }

      // 2. 处理新用户注册
      const newUserBucket: relationalStore.ValuesBucket = {
        'phone': phone,
        'nickname': `华为用户_${phone.slice(-4)}`,
        'login_status': 1,
        'last_login_time': currentTime,
        'is_vip': 0,
        'vip_expire_time': 0,
        'is_real_name': 0,
      };

      const rowId = await rdbHelper.insert(TABLE_NAME, newUserBucket);
      if (rowId <= 0) {
        throw new Error('Insert failed')
      };
      // 构造并返回新用户对象
      const newUser = new User();
      newUser.userId = rowId > 0 ? rowId : 1;
      newUser.phone = phone;
      newUser.gender = 2;
      newUser.nickname = '华为用户';
      newUser.loginStatus = 1;
      newUser.lastLoginTime = currentTime;
      newUser.isRealName = 0;
      return newUser;
    } catch (error) {
      Logger.error(TAG, `Login error: ${JSON.stringify(error)}`);
      throw new Error(error)
    } finally {
      // 无论成功失败，确保关闭结果集，防止内存泄漏
      if (resultSet) {
        resultSet.close();
      }
    }
  }

  // 用户退出登录
  public async userLogout(phone: string) {
    const condition = {
      field: 'phone',
      value: phone,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    const valueBucket: relationalStore.ValuesBucket = {
      'login_status': 0
    };
    try {
      await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
      return true;
    } catch (error) {
      Logger.error(TAG, `userLogout failed error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  // 查询用户信息
  public async queryUser(phone: string) {
    const condition = {
      field: 'phone',
      value: phone,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    let user: User | undefined = undefined;
    try {
      let resultSet = await rdbHelper.query(TABLE_NAME, [condition]);
      if (!resultSet) {
        Logger.error(TAG, 'rdb queryUser failed');
        return undefined;
      }
      if (resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
        user = User.fromResultSet(resultSet);
      }
      Logger.error(TAG, 'queryUser failed');
    } catch (error) {
      Logger.error(TAG, `queryUser failed error: ${JSON.stringify(error)}`);
    }
    return user;
  }

  // 更新用户信息
  public async updateUser(user: User) {
    // 条件
    const condition = {
      field: 'user_id',
      value: user.userId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    // 更新参数
    const valueBucket: relationalStore.ValuesBucket = {};
    if (user.phone) {
      valueBucket.phone = user.phone;
    }
    if (user.nickname) {
      valueBucket.nickname = user.nickname;
    }
    if (user.gender) {
      valueBucket.gender = user.gender;
    }
    if (user.avatar) {
      valueBucket.avatar = user.avatar;
    }
    if (user.isRealName) {
      valueBucket.is_real_name = user.isRealName;
    }
    if (user.realName) {
      valueBucket.real_name = user.realName;
    }
    if (user.idCardMask) {
      valueBucket.id_card_mask = user.idCardMask;
    }
    if (user.isVip !== undefined) {
      valueBucket.is_vip = Number(user.isVip);
    }
    if (user.vipExpireTime !== undefined) {
      valueBucket.vip_expire_time = Number(user.vipExpireTime);
    }
    if (user.isClaimBenefit !== undefined) {
      valueBucket.is_claim_benefit = Number(user.isClaimBenefit);
    }
    if (user.points) {
      valueBucket.points = user.points;
    }
    try {
      let rows = await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
      Logger.info(TAG, `用户信息更新成功，受影响行数: ${rows}`);
      return rows > 0;
    } catch (err) {
      Logger.error(`更新失败: ${JSON.stringify(err)}`);
      return false;
    }
  }
}

const userDB = new UserDB();

export { userDB as UserDB };