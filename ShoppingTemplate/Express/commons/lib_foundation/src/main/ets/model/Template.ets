import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class Template {
  // 模板id
  id: number = 0;
  // 所属用户id
  userId: number = 0;
  // 模板名称
  name: string = '';
  // 物品id
  goodsId: number = 0;
  // 物品名称
  goodsName: string = '';
  // 物品重量
  goodsWeight: number = 0;
  // 物品体积
  goodsVolume: number = 0;
  // 实际寄件重量
  weight: number = 0;
  // 模板的寄件地址id
  senderAddressId: number = 0;
  // 模板的寄件人姓名
  senderName: string = '';
  // 模板的寄件人手机号
  senderPhone: string = '';
  // 模板的寄件地址
  senderFullAddress: string = '';
  // 模板的寄件省份
  senderProvince: string = '';
  // 模板的寄件城市
  senderCity: string = '';
  // 模板的收件地址id
  receiverAddressId: number = 0;
  // 模板的收件人姓名
  receiverName: string = '';
  // 模板的收件人手机号
  receiverPhone: string = '';
  // 模板的收件地址
  receiverFullAddress: string = '';
  // 模板的收件省份
  receiverProvince: string = '';
  // 模板的收件城市
  receiverCity: string = '';
  // 寄件方式
  shippingMethod: number = 0;
  // 支付方式
  paymentMethod: number = 0;
  // 上门取件时间
  pickupTime: string = '';
  // 模板创建时间
  createdAt: number = 0;
  // 模板更新时间
  updatedAt: number = 0;

  /**
   * 将数据库查询结果单行转换为 Template 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): Template {
    const template = new Template();
    // 1. 先获取字段对应的索引（Index）
    // 2. 根据索引获取对应类型的值
    try {
      template.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      template.userId = resultSet.getLong(resultSet.getColumnIndex('user_id'));
      template.name = resultSet.getString(resultSet.getColumnIndex('name'));
      // 物品信息
      template.goodsId = resultSet.getLong(resultSet.getColumnIndex('goods_id'));
      template.goodsName = resultSet.getString(resultSet.getColumnIndex('goods_name'));
      template.goodsWeight = resultSet.getLong(resultSet.getColumnIndex('goods_weight'));
      // 寄件信息
      template.senderAddressId = resultSet.getLong(resultSet.getColumnIndex('sender_address_id'));
      template.senderName = resultSet.getString(resultSet.getColumnIndex('sender_name'));
      template.senderPhone = resultSet.getString(resultSet.getColumnIndex('sender_phone'));
      template.senderProvince = resultSet.getString(resultSet.getColumnIndex('sender_province'));
      template.senderCity = resultSet.getString(resultSet.getColumnIndex('sender_city'));
      template.senderFullAddress = resultSet.getString(resultSet.getColumnIndex('sender_full_address'));
      // 收件信息
      template.receiverAddressId = resultSet.getLong(resultSet.getColumnIndex('receiver_address_id'));
      template.receiverName = resultSet.getString(resultSet.getColumnIndex('receiver_name'));
      template.receiverPhone = resultSet.getString(resultSet.getColumnIndex('receiver_phone'));
      template.receiverProvince = resultSet.getString(resultSet.getColumnIndex('receiver_province'));
      template.receiverCity = resultSet.getString(resultSet.getColumnIndex('receiver_city'));
      template.receiverFullAddress = resultSet.getString(resultSet.getColumnIndex('receiver_full_address'));

      template.shippingMethod = resultSet.getLong(resultSet.getColumnIndex('shipping_method'));
      template.paymentMethod = resultSet.getLong(resultSet.getColumnIndex('payment_method'));
      template.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'));
      template.updatedAt = resultSet.getLong(resultSet.getColumnIndex('updated_at'));

      // 处理可能为 null 的字段
      const weightIndex = resultSet.getColumnIndex('weight');
      if (resultSet.isColumnNull(weightIndex)) {
        template.weight = template.goodsWeight;
      } else {
        template.weight = resultSet.getLong(weightIndex);
      }
      const goodsVolumeIndex = resultSet.getColumnIndex('goods_volume');
      if (!resultSet.isColumnNull(goodsVolumeIndex)) {
        template.goodsVolume = resultSet.getLong(goodsVolumeIndex);
      }
      const pickupTimeIndex = resultSet.getColumnIndex('pickup_time');
      if (!resultSet.isColumnNull(pickupTimeIndex)) {
        template.pickupTime = resultSet.getString(pickupTimeIndex);
      }
    } catch (error) {
      Logger.error('Template', `template fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return template;
  }
}