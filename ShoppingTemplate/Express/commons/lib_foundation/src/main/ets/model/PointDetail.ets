import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class PointDetail {
  id: number = 0
  userId: number = 0
  amount: number = 0;
  description: string = '';
  createTime: number = 0;

  /**
   * 将数据库查询结果单行转换为 User 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): PointDetail {
    const pointDetail = new PointDetail();
    try {
      pointDetail.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      pointDetail.userId = resultSet.getLong(resultSet.getColumnIndex('user_id'));
      pointDetail.amount = resultSet.getLong(resultSet.getColumnIndex('amount'));
      pointDetail.description = resultSet.getString(resultSet.getColumnIndex('description'));
      pointDetail.createTime = resultSet.getLong(resultSet.getColumnIndex('create_time'));
    } catch (error) {
      Logger.error('PointDetail', `PointDetail fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return pointDetail;
  }
}