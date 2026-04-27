import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';

export class AddressBook {
  // 地址id
  addressId: number = 0;
  // 所属用户id
  userId: number = 0;
  // 联系人姓名
  name: string = '';
  // 联系人手机号
  phone: string = '';
  // 国家代码 (例如: CN)
  countryCode: string = '';
  // 国家
  country: string = '';
  // 省
  province: string= '';
  // 市
  city: string = '';
  // 区/县
  district: string = '';
  // 街道
  street: string = '';
  // 详细地址
  detail: string = '';
  // 是否为默认地址
  isDefault: boolean = false;
  // 地址创建时间
  createdAt: number = 0;
  // 地址更新时间
  updatedAt: number = 0;

  /**
   * 将数据库查询结果单行转换为 AddressBook 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): AddressBook {
    const addressBook = new AddressBook();
    // 1. 先获取字段对应的索引（Index）
    // 2. 根据索引获取对应类型的值
    try {
      addressBook.addressId = resultSet.getLong(resultSet.getColumnIndex('address_id'));
      addressBook.userId = resultSet.getLong(resultSet.getColumnIndex('user_id'));
      addressBook.name = resultSet.getString(resultSet.getColumnIndex('name'));
      addressBook.phone = resultSet.getString(resultSet.getColumnIndex('phone'));
      addressBook.countryCode = resultSet.getString(resultSet.getColumnIndex('country_code'));
      addressBook.country = resultSet.getString(resultSet.getColumnIndex('country'));
      addressBook.province = resultSet.getString(resultSet.getColumnIndex('province'));
      addressBook.city = resultSet.getString(resultSet.getColumnIndex('city'));
      addressBook.district = resultSet.getString(resultSet.getColumnIndex('district'));
      addressBook.street = resultSet.getString(resultSet.getColumnIndex('street'));
      addressBook.detail = resultSet.getString(resultSet.getColumnIndex('detail'));
      addressBook.isDefault = resultSet.getLong(resultSet.getColumnIndex('is_default'))  === 1;
      addressBook.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'));
      addressBook.updatedAt = resultSet.getLong(resultSet.getColumnIndex('updated_at'));
    } catch (error) {
      Logger.error('AddressBook', `addressBook fromResultSet failed: error: ${JSON.stringify(error)}`)
    }

    return addressBook;
  }
}