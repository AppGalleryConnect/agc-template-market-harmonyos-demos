import { relationalStore } from '@kit.ArkData';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { AddressBook } from '../model/AddressBook';

const TAG = '[AddressBookDB]';
const TABLE_NAME = 'address_book';

// 地址表
class AddressBookDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        address_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        country_code TEXT NOT NULL,
        country TEXT NOT NULL,
        province TEXT NOT NULL,
        city TEXT NOT NULL,
        district TEXT NOT NULL,
        street TEXT NOT NULL,
        detail TEXT NOT NULL,
        created_at INTEGER DEFAULT 0,
        updated_at INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE
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

  // 新增地址
  public async addAddress(addressInfo: AddressBook) {
    return rdbHelper.runTransaction(async () => {
      const addressBucket: relationalStore.ValuesBucket = {
        'user_id': addressInfo.userId,
        'name': addressInfo.name,
        'phone': addressInfo.phone,
        'country_code': addressInfo.countryCode,
        'country': addressInfo.country,
        'province': addressInfo.province,
        'city': addressInfo.city,
        'district': addressInfo.district,
        'street': addressInfo.street,
        'detail': addressInfo.detail,
        'created_at': addressInfo.createdAt,
        'updated_at': addressInfo.updatedAt,
        'is_default': Number(addressInfo.isDefault),
      };
      if (addressInfo.isDefault) {
        // 重置该用户下所有现有的默认地址
        const condition = {
          field: 'user_id',
          value: addressInfo.userId,
          operator: DBOperator.EQUAL
        } as TablePredicate;
        const valueBucket: relationalStore.ValuesBucket = {
          'is_default': 0
        }
        await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
      }
      // 插入并获取生成的自增 ID
      const rowId = await rdbHelper.insert(TABLE_NAME, addressBucket);
      return rowId;
    });
  }

  // 查询地址列表
  public async queryAddressList(userId: number) {
    // 条件1
    const condition1 = {
      field: 'user_id',
      value: userId,
      operator: DBOperator.EQUAL
    } as TablePredicate;
    // 条件2
    const condition2 = {
      field: 'updated_at',
      operator: DBOperator.ORDER_BY_DESC
    } as TablePredicate;

    let resultSet = await rdbHelper.query(TABLE_NAME, [condition1, condition2]);
    if (!resultSet) {
      return [];
    }
    let addressList: AddressBook[] = [];
    try {
      while (resultSet.goToNextRow()) {
        addressList.push(AddressBook.fromResultSet(resultSet));
      }
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `queryAddressList failed. error: ${JSON.stringify(error)}`)
    }
    return addressList;
  }

  // 查询默认地址
  public async queryDefaultAddress(userId: number) {
    const querySQL = `
      SELECT * FROM ${TABLE_NAME}
      WHERE user_id = ?
      ORDER BY is_default DESC, updated_at DESC
      LIMIT 1
    `
    const resultSet = await rdbHelper.querySql(querySQL, userId);
    if (!resultSet) {
      return undefined;
    }
    let address: AddressBook[] = [];
    try {
      if (resultSet.goToFirstRow()) {
        address.push(AddressBook.fromResultSet(resultSet));
      }
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `queryTemplateList failed. error: ${JSON.stringify(error)}`)
    }
    return address[0];
  }

  // 更新地址信息
  public async updateAddressBook(data: AddressBook, isSetDefault: boolean = false) {
    return rdbHelper.runTransaction(async () => {
      // 条件
      const condition = {
        field: 'address_id',
        value: data.addressId,
        operator: DBOperator.EQUAL
      } as TablePredicate;

      const valueBucket: relationalStore.ValuesBucket = {
        'name': data.name,
        'phone': data.phone,
        'country_code': data.countryCode,
        'country': data.country,
        'province': data.province,
        'city': data.city,
        'district': data.district,
        'street': data.street,
        'detail': data.detail,
        'updated_at': data.updatedAt,
        'is_default': Number(data.isDefault),
      };
      if (isSetDefault || data.isDefault) {
        // 重置该用户下所有现有的默认地址
        const condition = {
          field: 'user_id',
          value: data.userId,
          operator: DBOperator.EQUAL
        } as TablePredicate;
        const valueBucket: relationalStore.ValuesBucket = {
          'is_default': 0
        }
        await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
      }
      const rows = await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
      return rows;
    });
  }

  // 删除地址
  public async deleteAddress(addressId: number) {
    const condition = {
      field: 'address_id',
      value: addressId,
      operator: DBOperator.EQUAL
    } as TablePredicate

    const rowId = await rdbHelper.delete(TABLE_NAME, [condition]);
    return rowId > 0;
  }
}

const addressBookDB = new AddressBookDB();

export { addressBookDB as AddressBookDB };