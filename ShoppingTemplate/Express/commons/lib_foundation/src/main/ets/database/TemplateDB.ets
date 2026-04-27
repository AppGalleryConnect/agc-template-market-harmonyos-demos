import { relationalStore } from '@kit.ArkData';
import { DBOperator, TablePredicate, TableSchema } from '../common/Constant';
import { Template } from '../model/Template';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';

const TAG = '[TemplateDB]';
const TABLE_NAME = 'shipping_template';

class TemplateDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        goods_id INTEGER,
        weight REAL,
        sender_address_id INTEGER,
        sender_name TEXT,
        sender_phone TEXT,
        sender_province TEXT,
        sender_city TEXT,
        sender_full_address TEXT,
        receiver_address_id INTEGER,
        receiver_name TEXT,
        receiver_phone TEXT,
        receiver_province TEXT,
        receiver_city TEXT,
        receiver_full_address TEXT,
        shipping_method INTEGER DEFAULT 0,
        payment_method INTEGER DEFAULT 0,
        pickup_time TEXT,
        created_at INTEGER DEFAULT 0,
        updated_at INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE,
        FOREIGN KEY (goods_id) REFERENCES goods (id) ON DELETE SET NULL,
        FOREIGN KEY (sender_address_id) REFERENCES address_book (address_id) ON DELETE SET NULL,
        FOREIGN KEY (receiver_address_id) REFERENCES address_book (address_id) ON DELETE SET NULL
      )`,
  }

  // 创建表结构
  public async createTable() {
    try {
      await rdbHelper.createTables(this.tableSchema);
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 查询寄件模板列表
  public async queryTemplateList(userId: number) {
    const querySQL = `
      SELECT
        t.id, t.user_id, t.name, t.goods_id, t.weight,
        t.sender_address_id, t.sender_name, t.sender_phone,
        t.sender_province, t.sender_city, t.sender_full_address,
        t.receiver_address_id, t.receiver_name, t.receiver_phone,
        t.receiver_province, t.receiver_city, t.receiver_full_address,
        t.pickup_time, t.shipping_method, t.payment_method, t.created_at, t.updated_at,
        g.name AS goods_name,
        g.weight AS goods_weight,
        g.volume AS goods_volume
      FROM shipping_template t
      LEFT JOIN goods g ON t.goods_id = g.id
      WHERE t.user_id = ?
      ORDER BY t.updated_at DESC, t.id DESC
    `;
    let templateList: Template[] = [];
    try {
      const resultSet = await rdbHelper.querySql(querySQL, userId);
      if (!resultSet) {
        return [];
      }
      while (resultSet.goToNextRow()) {
        templateList.push(Template.fromResultSet(resultSet));
      }
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `queryTemplateList failed. error: ${JSON.stringify(error)}`)
    }
    return templateList;
  }

  // 查询寄件模板详情
  public async queryTemplateDetail(templateId: number) {
    const querySQL = `
      SELECT
        t.id, t.user_id, t.name, t.goods_id, t.weight,
        t.sender_address_id, t.sender_name, t.sender_phone,
        t.sender_province, t.sender_city, t.sender_full_address,
        t.receiver_address_id, t.receiver_name, t.receiver_phone,
        t.receiver_province, t.receiver_city, t.receiver_full_address,
        t.pickup_time, t.shipping_method, t.payment_method, t.created_at, t.updated_at,
        g.name AS goods_name,
        g.weight AS goods_weight,
        g.volume AS goods_volume
      FROM shipping_template t
      LEFT JOIN goods g ON t.goods_id = g.id
      WHERE t.id = ?
      LIMIT 1
    `;
    let templateDetail: Template | null = null
    try {
      const resultSet = await rdbHelper.querySql(querySQL, templateId);
      if (resultSet?.goToFirstRow()) {
        templateDetail = Template.fromResultSet(resultSet);
      }
      resultSet?.close();
    } catch (error) {
      Logger.error(TAG, `queryTemplateDetail failed. error: ${JSON.stringify(error)}`)
    }
    return templateDetail;
  }

  // 新增寄件模板
  public async addTemplate(template: Template) {
    const templateBucket: relationalStore.ValuesBucket = {
      'user_id': template.userId,
      'name': template.name,
      'goods_id': template.goodsId,
      'sender_address_id': template.senderAddressId,
      'sender_name': template.senderName,
      'sender_phone': template.senderPhone,
      'sender_province': template.senderProvince,
      'sender_city': template.senderCity,
      'sender_full_address': template.senderFullAddress,
      'receiver_address_id': template.receiverAddressId,
      'receiver_name': template.receiverName,
      'receiver_phone': template.receiverPhone,
      'receiver_province': template.receiverProvince,
      'receiver_city': template.receiverCity,
      'receiver_full_address': template.receiverFullAddress,
      'weight': template.weight,
      'shipping_method': template.shippingMethod,
      'payment_method': template.paymentMethod,
      'created_at': template.createdAt,
      'updated_at': template.updatedAt,
    };
    if (template.pickupTime) {
      templateBucket.pickup_time = template.pickupTime;
    }
    // 插入并获取生成的自增 ID
    const rowId = await rdbHelper.insert(TABLE_NAME, templateBucket);
    return rowId;
  }

  // 更新寄件模板
  public async updateTemplate(template: Template) {
    // 条件
    const condition = {
      field: 'id',
      value: template.id,
      operator: DBOperator.EQUAL
    } as TablePredicate;

    const valueBucket: relationalStore.ValuesBucket = {};
    // 名称
    if (template.name) {
      valueBucket.name = template.name;
    }
    // 物品的id
    if (template.goodsId) {
      valueBucket.goods_id = template.goodsId
    }
    // 寄件人信息
    if (template.senderAddressId) {
      valueBucket.sender_address_id = template.senderAddressId
    }
    if (template.senderName) {
      valueBucket.sender_name = template.senderName
    }
    if (template.senderPhone) {
      valueBucket.sender_phone = template.senderPhone
    }
    if (template.senderProvince) {
      valueBucket.sender_province = template.senderProvince
    }
    if (template.senderCity) {
      valueBucket.sender_city = template.senderCity
    }
    if (template.senderFullAddress) {
      valueBucket.sender_full_address = template.senderFullAddress
    }
    // 收件人信息
    if (template.receiverAddressId) {
      valueBucket.receiver_address_id = template.receiverAddressId
    }
    if (template.receiverName) {
      valueBucket.receiver_name = template.receiverName
    }
    if (template.receiverPhone) {
      valueBucket.receiver_phone = template.receiverPhone
    }
    if (template.receiverProvince) {
      valueBucket.receiver_province = template.receiverProvince
    }
    if (template.receiverCity) {
      valueBucket.receiver_city = template.receiverCity
    }
    if (template.receiverFullAddress) {
      valueBucket.receiver_full_address = template.receiverFullAddress
    }
    // 模板包裹的重量
    if (template.weight) {
      valueBucket.weight = template.weight;
    }
    // 寄件方式
    if (template.shippingMethod !== undefined) {
      valueBucket.shipping_method = template.shippingMethod;
    }
    // 支付方式
    if (template.paymentMethod !== undefined) {
      valueBucket.payment_method = template.paymentMethod;
    }
    // 上门时间
    if (template.pickupTime) {
      valueBucket.pickup_time = template.pickupTime;
    }
    // 更新时间
    if (template.updatedAt) {
      valueBucket.updated_at = template.updatedAt;
    }

    const rows = await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);
    return rows;
  }

  // 删除地址
  public async deleteTemplate(id: number) {
    const condition = {
      field: 'id',
      value: id,
      operator: DBOperator.EQUAL
    } as TablePredicate

    const rowId = await rdbHelper.delete(TABLE_NAME, [condition]);
    return rowId
  }
}

const templateDB = new TemplateDB();

export { templateDB as TemplateDB };