import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class Goods {
  id: number = 0;
  name: string = '';
  weight: number = 0;
  volume: number = 0;

  /**
   * 将数据库查询结果单行转换为 Goods 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): Goods {
    const goods = new Goods();
    // 1. 先获取字段对应的索引（Index）
    // 2. 根据索引获取对应类型的值
    try {
      goods.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      goods.name = resultSet.getString(resultSet.getColumnIndex('name'));
      goods.weight = resultSet.getLong(resultSet.getColumnIndex('weight'));
      goods.volume = resultSet.getLong(resultSet.getColumnIndex('volume'));
    } catch (error) {
      Logger.error('Goods', `Goods fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return goods;
  }
}

export const defaultGoodsList: Goods[] = [
  { id: 1, name: '文件', weight: 1, volume: 0 },
  { id: 2, name: '衣服', weight: 1, volume: 0 },
  { id: 3, name: '发票', weight: 1, volume: 0 },
  { id: 4, name: '茶叶', weight: 1, volume: 0 },
  { id: 5, name: '手机', weight: 1, volume: 0 },
  { id: 6, name: '白酒', weight: 1, volume: 0 },
  { id: 7, name: '行李', weight: 5, volume: 0 },
  { id: 8, name: '灯具', weight: 2, volume: 0 },
  { id: 9, name: '五金配件', weight: 2, volume: 0 },
  { id: 10, name: '茅台', weight: 3, volume: 0 },
  { id: 11, name: '其他', weight: 1, volume: 0 },
]