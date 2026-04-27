import { relationalStore } from '@kit.ArkData';
import { ParcelStatus } from '../common/CommonEnum';
import { Logger } from '../utils/Logger';
import { Logistics } from './Logistics';


export class Parcel {
  // 运单id
  id: number = 0;
  // 运单号
  parcelNumber: string = '';
  // 快递公司
  expressCompany: string = '';
  // 使用的优惠券id
  couponId?: number = 0;
  // 寄件码
  dropOffCode: string = '';
  // 寄件人姓名
  senderName: string = '';
  // 寄件人手机号
  senderPhone: string = '';
  // 寄件人地址id
  senderAddressId: number = 0;
  // 寄件人地址
  senderFullAddress: string = '';
  // 寄件人省份
  senderProvince: string = '';
  // 寄件人城市
  senderCity: string = '';
  // 寄件人位置纬度
  senderLatitude: number = 0;
  // 寄件人位置经度
  senderLongitude: number = 0;
  // 收件人姓名
  receiverName: string = '';
  // 收件人手机号
  receiverPhone: string = '';
  // 收件地址id
  receiverAddressId: number = 0;
  // 收件人地址
  receiverFullAddress: string = '';
  // 收件人省份
  receiverProvince: string = '';
  // 收件人城市
  receiverCity: string = '';
  // 收件人位置纬度
  receiverLatitude: number = 0;
  // 收件人位置经度
  receiverLongitude: number = 0;
  // 运单状态
  status: ParcelStatus = ParcelStatus.AWAITING_PICKUP;
  // 支付金额
  price: number = 0;
  // 付款方式 1：寄付现结  2：到付
  payMethod: number = 1;
  // 是否支付 0：待支付  1：已支付
  paymentStatus: number = 0;
  // 寄件方式 1：上门取件  2：服务点自寄
  shippingMethod: number = 1;
  // 物品名称
  goodsName: string = '';
  // 格口
  grid: string = '';
  // 包裹重量
  weight: number = 0;
  // 创建时间
  createTime: number = 0;
  // 更新时间
  updateTime: number = 0;
  // 取消时间
  cancelTime: number = 0;
  // 预计上门取件时间
  pickupTime: number = 0;
  // 预计到达时间
  estimatedArrivalTime: number = 0;
  // 签收时间
  deliveryTime: number = 0;
  // 备注
  remark: string = '';

  /**
   * 将数据库查询结果单行转换为 Goods 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): Parcel {
    const parcel = new Parcel();
    // 1. 先获取字段对应的索引（Index）
    // 2. 根据索引获取对应类型的值
    try {
      parcel.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      parcel.parcelNumber = resultSet.getString(resultSet.getColumnIndex('parcel_number'));
      parcel.expressCompany = resultSet.getString(resultSet.getColumnIndex('express_company'));
      parcel.couponId = resultSet.getLong(resultSet.getColumnIndex('coupon_id'));
      parcel.senderName = resultSet.getString(resultSet.getColumnIndex('sender_name'));
      parcel.senderPhone = resultSet.getString(resultSet.getColumnIndex('sender_phone'));
      parcel.senderAddressId = resultSet.getLong(resultSet.getColumnIndex('sender_address_id'));
      parcel.senderFullAddress = resultSet.getString(resultSet.getColumnIndex('sender_full_address'));
      parcel.senderProvince = resultSet.getString(resultSet.getColumnIndex('sender_province'));
      parcel.senderCity = resultSet.getString(resultSet.getColumnIndex('sender_city'));
      parcel.senderLatitude = resultSet.getDouble(resultSet.getColumnIndex('sender_latitude'));
      parcel.senderLongitude = resultSet.getDouble(resultSet.getColumnIndex('sender_longitude'));
      parcel.receiverName = resultSet.getString(resultSet.getColumnIndex('receiver_name'));
      parcel.receiverPhone = resultSet.getString(resultSet.getColumnIndex('receiver_phone'));
      parcel.receiverAddressId = resultSet.getLong(resultSet.getColumnIndex('receiver_address_id'));
      parcel.receiverFullAddress = resultSet.getString(resultSet.getColumnIndex('receiver_full_address'));
      parcel.receiverProvince = resultSet.getString(resultSet.getColumnIndex('receiver_province'));
      parcel.receiverCity = resultSet.getString(resultSet.getColumnIndex('receiver_city'));
      parcel.receiverLatitude = resultSet.getDouble(resultSet.getColumnIndex('receiver_latitude'));
      parcel.receiverLongitude = resultSet.getDouble(resultSet.getColumnIndex('receiver_longitude'));
      parcel.status = resultSet.getLong(resultSet.getColumnIndex('status'));
      parcel.price = resultSet.getDouble(resultSet.getColumnIndex('price'));
      parcel.payMethod = resultSet.getLong(resultSet.getColumnIndex('pay_method'));
      parcel.paymentStatus = resultSet.getLong(resultSet.getColumnIndex('payment_status'));
      parcel.shippingMethod = resultSet.getLong(resultSet.getColumnIndex('shipping_method'));
      parcel.weight = resultSet.getDouble(resultSet.getColumnIndex('weight'));
      parcel.createTime = resultSet.getLong(resultSet.getColumnIndex('create_time'));
      parcel.updateTime = resultSet.getLong(resultSet.getColumnIndex('update_time'));
      parcel.goodsName = resultSet.getString(resultSet.getColumnIndex('goods_name'));

      // 处理可能为null的情况
      const dropOffCodeIndex = resultSet.getColumnIndex('drop_off_code');
      if (!resultSet.isColumnNull(dropOffCodeIndex)) {
        parcel.dropOffCode = resultSet.getString(dropOffCodeIndex);
      }
      const gridIndex = resultSet.getColumnIndex('grid');
      if (!resultSet.isColumnNull(gridIndex)) {
        parcel.grid = resultSet.getString(gridIndex);
      }
      const remarkIndex = resultSet.getColumnIndex('remark');
      if (!resultSet.isColumnNull(remarkIndex)) {
        parcel.remark = resultSet.getString(remarkIndex);
      }
      const cancelTimeIndex = resultSet.getColumnIndex('cancel_time');
      if (!resultSet.isColumnNull(cancelTimeIndex)) {
        parcel.cancelTime = resultSet.getLong(cancelTimeIndex);
      }
      const pickupTimeIndex = resultSet.getColumnIndex('pickup_time');
      if (!resultSet.isColumnNull(pickupTimeIndex)) {
        parcel.pickupTime = resultSet.getLong(pickupTimeIndex);
      }
      const estimatedArrivalTimeIndex = resultSet.getColumnIndex('estimated_arrival_time');
      if (!resultSet.isColumnNull(estimatedArrivalTimeIndex)) {
        parcel.estimatedArrivalTime = resultSet.getLong(estimatedArrivalTimeIndex);
      }
      const deliveryTimeIndex = resultSet.getColumnIndex('delivery_time');
      if (!resultSet.isColumnNull(deliveryTimeIndex)) {
        parcel.deliveryTime = resultSet.getLong(deliveryTimeIndex);
      }
    } catch (error) {
      Logger.error('Goods', `Parcel fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return parcel;
  }
}

export interface ParcelWithLogistics {
  detail: Parcel,
  logs: Logistics[]
}