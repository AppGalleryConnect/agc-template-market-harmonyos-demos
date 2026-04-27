import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class UserSign {
  id: number = 0
  userId: number = 0
  signMask: number = 0;
  weekStartTime: number = 0;
  lastSignTime: number = 0;

  /**
   * 将数据库查询结果单行转换为 User 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): UserSign {
    const userSign = new UserSign();
    try {
      userSign.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      userSign.userId = resultSet.getLong(resultSet.getColumnIndex('user_id'));
      userSign.weekStartTime = resultSet.getLong(resultSet.getColumnIndex('week_start_time'));
      userSign.signMask = resultSet.getLong(resultSet.getColumnIndex('sign_mask'));
      userSign.lastSignTime = resultSet.getLong(resultSet.getColumnIndex('last_sign_time'));
    } catch (error) {
      Logger.error('UserSign', `UserSign fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return userSign;
  }
}