import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class Coupon {
  // ID
  id: number = 0;
  // 名称
  name: string = '';
  // 使用限制说明
  usageRestriction: string = '';
  // 优惠开始时间
  startTime: number = 0;
  // 优惠结束时间
  endTime: number = 0;
  // 优惠券状态: 0-待使用; 1-已使用; 2-已过期
  couponStatus: number = 0;
  // 优惠类型：0-满减; 1-立减; 2-折扣
  discountType: number = 0;
  // 满减时的全额
  fullAmount: number = 0;
  // 折扣金额
  discountAmount: number = 0;
  // 折扣
  discountCoefficient: number = 0;
  // 创建时间
  createdTime: number = 0;
  // 优惠券已领取还是未领取时，在userCoupon表对应的id
  receivedId?: number = 0;

  /**
   * 从数据库结果集中解析单行数据并转换为 Coupon 对象
   * @param resultSet 关系型数据库查询结果集
   * @returns 填充好的 Coupon 实例
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): Coupon {
    const coupon = new Coupon();
    try {
      // 使用 getColumnIndex 获取索引，确保代码的健壮性
      coupon.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      coupon.name = resultSet.getString(resultSet.getColumnIndex('name'));
      coupon.usageRestriction = resultSet.getString(resultSet.getColumnIndex('usage_restriction'));
      coupon.startTime = resultSet.getLong(resultSet.getColumnIndex('start_time'));
      coupon.endTime = resultSet.getLong(resultSet.getColumnIndex('end_time'));
      coupon.couponStatus = resultSet.getLong(resultSet.getColumnIndex('coupon_status'));
      coupon.discountType = resultSet.getLong(resultSet.getColumnIndex('discount_type'));
      // 涉及金额或系数的字段使用 getDouble
      coupon.fullAmount = resultSet.getDouble(resultSet.getColumnIndex('full_amount'));
      coupon.discountAmount = resultSet.getDouble(resultSet.getColumnIndex('discount_amount'));
      coupon.discountCoefficient = resultSet.getDouble(resultSet.getColumnIndex('discount_coefficient'));
      coupon.createdTime = resultSet.getLong(resultSet.getColumnIndex('created_time'));
    } catch (error) {
      Logger.error('Coupon', `Coupon fromResultSet failed: error: ${JSON.stringify(error)}`)
    }
    return coupon;
  }
}