import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class Logistics {
  id: number = 0;
  parcelNumber: string = '';
  occurrenceTime: number = 0;
  description: string = '';
  location: string = '';
  nodeStatus: number = 0;
  operatorName: string = '';
  operatorPhone: string = '';

  /**
   * 将数据库查询结果单行转换为 Logistics 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): Logistics {
    const logistics = new Logistics();
    // 1. 先获取字段对应的索引（Index）
    // 2. 根据索引获取对应类型的值
    try {
      logistics.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      logistics.parcelNumber = resultSet.getString(resultSet.getColumnIndex('parcel_number'));
      logistics.occurrenceTime = resultSet.getLong(resultSet.getColumnIndex('occurrence_time'));
      logistics.description = resultSet.getString(resultSet.getColumnIndex('description'));
      logistics.location = resultSet.getString(resultSet.getColumnIndex('location'));
      logistics.nodeStatus = resultSet.getLong(resultSet.getColumnIndex('node_status'));
      logistics.operatorName = resultSet.getString(resultSet.getColumnIndex('operator_name'));
      logistics.operatorPhone = resultSet.getString(resultSet.getColumnIndex('operator_phone'));
    } catch (error) {
      Logger.error('Logistics', `Logistics fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return logistics;
  }
}