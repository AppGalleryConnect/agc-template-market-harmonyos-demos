import {
  DBOperator,
  RULES,
  STATUS_DESCRIPTION_MAP,
  STATUS_OPERATOR_MAP,
  TablePredicate,
  TableSchema,
} from '../common/Constant';
import { Logger } from '../utils/Logger';
import { rdbHelper } from './RdbHelper';
import { relationalStore, ValueType } from '@kit.ArkData';
import { Parcel, ParcelWithLogistics } from '../model/Parcel';
import { MockData } from '../http/MockData';
import { Logistics } from '../model/Logistics';
import { LogisticsDB } from './LogisticsDB';
import { ParcelStatus, PayMethod, PayStatus } from '../common/CommonEnum';
import { CommonUtil } from '../utils/CommonUtil';

const TAG = '[ParcelDB]';
const TABLE_NAME = 'parcel';

// 快递物流运单表
class ParcelDB {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcel_number TEXT NOT NULL UNIQUE,
        express_company TEXT NOT NULL,
        coupon_id INTEGER,
        remark TEXT,
        drop_off_code TEXT,
        sender_name TEXT NOT NULL,
        sender_phone TEXT NOT NULL,
        sender_address_id INTEGER NOT NULL,
        sender_full_address TEXT NOT NULL,
        sender_province TEXT NOT NULL,
        sender_city TEXT NOT NULL,
        sender_latitude REAL DEFAULT 32.0,
        sender_longitude REAL DEFAULT 118.8,
        receiver_name TEXT NOT NULL,
        receiver_phone TEXT NOT NULL,
        receiver_address_id INTEGER NOT NULL,
        receiver_full_address TEXT NOT NULL,
        receiver_province TEXT NOT NULL,
        receiver_city TEXT NOT NULL,
        receiver_latitude REAL DEFAULT 32.0,
        receiver_longitude REAL DEFAULT 118.8,
        status INTEGER DEFAULT 0,
        price REAL DEFAULT 0.00,
        pay_method INTEGER DEFAULT 1,
        payment_status INTEGER DEFAULT 0,
        shipping_method INTEGER DEFAULT 1,
        goods_name TEXT NOT NULL,
        grid TEXT,
        weight REAL,
        create_time INTEGER,
        update_time INTEGER,
        cancel_time INTEGER,
        pickup_time INTEGER,
        estimated_arrival_time INTEGER,
        delivery_time INTEGER
      )`,
    indexes: [
      `CREATE INDEX IF NOT EXISTS index_sender_phone ON ${TABLE_NAME} (sender_phone)`,
      `CREATE INDEX IF NOT EXISTS index_receiver_phone ON ${TABLE_NAME} (receiver_phone)`,
    ],
  }

  // 创建表结构
  public createTable() {
    try {
      rdbHelper.createTables(this.tableSchema).then(() => {
        this.insertReceiverParcels();
      })
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 插入默认的收件运单
  async insertReceiverParcels() {
    // 检查表中是否已有数据
    const checkSql = `SELECT count(*) as count FROM ${TABLE_NAME}`;
    const resultSet = await rdbHelper.querySql(checkSql, []);
    try {
      if (resultSet?.goToFirstRow()) {
        const count = resultSet?.getLong(0);
        resultSet.close();
        if (count > 0) {
          Logger.info(TAG, '表中已有数据，跳过默认插入');
          return;
        }
      }
    } catch (error) {
      Logger.error(TAG, `query failed. error: ${JSON.stringify(error)}`);
    }
    // 插入默认的收件运单
    const valueRows = MockData.RECEIVER_ORDER_LIST.map(item => {
      const escape = (str: ValueType) => String(str).replace(/'/g, `''`);
      const values = [
        `'${escape(item.parcelNumber)}'`,
        `'${escape(item.expressCompany)}'`,
        `'${escape(item.remark)}'`,
        `'${escape(item.dropOffCode)}'`,
        `'${escape(item.senderName)}'`,
        `'${escape(item.senderPhone)}'`,
        item.senderAddressId,
        `'${escape(item.senderFullAddress)}'`,
        `'${escape(item.senderProvince)}'`,
        `'${escape(item.senderCity)}'`,
        item.senderLatitude,
        item.senderLongitude,
        `'${escape(item.receiverName)}'`,
        `'${escape(item.receiverPhone)}'`,
        item.receiverAddressId,
        `'${escape(item.receiverFullAddress)}'`,
        `'${escape(item.receiverProvince)}'`,
        `'${escape(item.receiverCity)}'`,
        item.receiverLatitude,
        item.receiverLongitude,
        // 数字不需要引号
        item.status,
        item.price,
        item.payMethod,
        item.paymentStatus,
        item.shippingMethod,
        `'${escape(item.goodsName)}'`,
        `'${escape(item.grid)}'`,
        item.weight,
        item.createTime,
        item.updateTime,
        item.cancelTime,
        item.pickupTime,
        item.estimatedArrivalTime,
        item.deliveryTime,
      ];
      return `(${values.join(', ')})`;
    }).join(', ');
    const sql = `INSERT OR IGNORE INTO ${TABLE_NAME} (
      parcel_number, express_company, remark, drop_off_code, sender_name, sender_phone,
      sender_address_id, sender_full_address, sender_province, sender_city, sender_latitude,
      sender_longitude, receiver_name, receiver_phone, receiver_address_id, receiver_full_address,
      receiver_province, receiver_city, receiver_latitude, receiver_longitude,
      status, price, pay_method, payment_status, shipping_method, goods_name, grid, weight, create_time,
      update_time, cancel_time, pickup_time, estimated_arrival_time, delivery_time
    ) VALUES ${valueRows};`;

    await rdbHelper.executeSql(sql);
  }

  // 创建运单
  public async createParcel(parcel: Parcel) {
    return rdbHelper.runTransaction(async () => {
      const parcelBucket: relationalStore.ValuesBucket = {
        'parcel_number': parcel.parcelNumber,
        'express_company': parcel.expressCompany,
        'sender_name': parcel.senderName,
        'sender_phone': parcel.senderPhone,
        'sender_address_id': parcel.senderAddressId,
        'sender_full_address': parcel.senderFullAddress,
        'sender_province': parcel.senderProvince,
        'sender_city': parcel.senderCity,
        'sender_latitude': parcel.senderLatitude,
        'sender_longitude': parcel.senderLongitude,
        'receiver_name': parcel.receiverName,
        'receiver_phone': parcel.receiverPhone,
        'receiver_address_id': parcel.receiverAddressId,
        'receiver_full_address': parcel.receiverFullAddress,
        'receiver_province': parcel.receiverProvince,
        'receiver_city': parcel.receiverCity,
        'receiver_latitude': parcel.receiverLatitude,
        'receiver_longitude': parcel.receiverLongitude,
        'status': parcel.status,
        'price': parcel.price,
        'pay_method': parcel.payMethod,
        'payment_status': parcel.paymentStatus,
        'goods_name': parcel.goodsName,
        'weight': parcel.weight,
        'create_time': parcel.createTime,
        'update_time': parcel.updateTime,
      };
      if (parcel.shippingMethod) {
        parcelBucket.shipping_method = parcel.shippingMethod;
      }
      if (parcel.grid) {
        parcelBucket.grid = parcel.grid;
      }
      if (parcel.dropOffCode) {
        parcelBucket.drop_off_code = parcel.dropOffCode;
      }
      if (parcel.estimatedArrivalTime) {
        parcelBucket.estimated_arrival_time = parcel.estimatedArrivalTime;
      }
      if (parcel.pickupTime) {
        parcelBucket.pickup_time = parcel.pickupTime;
      }
      if (parcel.couponId) {
        parcelBucket.coupon_id = parcel.couponId;
      }
      // 插入运单表
      await rdbHelper.insert(TABLE_NAME, parcelBucket);
      // 插入物流轨迹表
      const logisticsData = {
        parcelNumber: parcel.parcelNumber,
        occurrenceTime: parcel.updateTime,
        description: CommonUtil.handleDes(STATUS_DESCRIPTION_MAP.get(parcel.status), parcel),
        location: parcel.status > 3 ? parcel.receiverCity : parcel.senderCity,
        nodeStatus: parcel.status,
        operatorName: '',
        operatorPhone: '',
      } as Logistics;
      // 插入并获取生成的自增 ID
      const rowId = await LogisticsDB.createLogistics(logisticsData)
      return rowId;
    })
  }

  // 查询运单列表
  public async queryParcelList() {
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('update_time');
    let resultSet = await rdbHelper.queryByPredicates(predicates);
    if (!resultSet) {
      return [];
    }
    let parcelList: Parcel[] = [];
    try {
      while (resultSet.goToNextRow()) {
        parcelList.push(Parcel.fromResultSet(resultSet));
      }
      resultSet.close();
    } catch (error) {
      Logger.error(TAG, `queryParcelList failed. error: ${JSON.stringify(error)}`)
    }
    return parcelList;
  }

  // 查询运单列表最新一条数据
  public async queryLatestParcel() {
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('update_time');
    predicates.limitAs(1);
    let resultSet = await rdbHelper.queryByPredicates(predicates);
    let parcel: Parcel | undefined = undefined;
    try {
      if (resultSet && resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
        parcel = Parcel.fromResultSet(resultSet);
      }
      resultSet?.close();
    } catch (error) {
      Logger.error(TAG, `queryParcelList failed. error: ${JSON.stringify(error)}`)
    }

    let logisticsList: Logistics[] = [];
    if (parcel) {
      let logisticsPredicates = new relationalStore.RdbPredicates('logistics');
      logisticsPredicates.equalTo('parcel_number', parcel.parcelNumber)
      logisticsPredicates.orderByDesc('occurrence_time');
      logisticsPredicates.limitAs(1);
      let logisticResultSet = await rdbHelper.queryByPredicates(logisticsPredicates);
      try {
        if (logisticResultSet && logisticResultSet.rowCount > 0 && logisticResultSet.goToFirstRow()) {
          logisticsList.push(Logistics.fromResultSet(logisticResultSet));
        }
        logisticResultSet?.close();
      } catch (error) {
        Logger.error(TAG, `query logistics List failed. error: ${JSON.stringify(error)}`)
      }
    }
    return {
      detail: parcel,
      logs: logisticsList,
    } as ParcelWithLogistics;
  }

  // 查询运单详情
  public async queryParcelDetail(parcelNo: string) {
    const sql = `SELECT * FROM ${TABLE_NAME} WHERE parcel_number = ? LIMIT 1`;
    let detail: Parcel | null = null;
    try {
      const resultSet = await rdbHelper.querySql(sql, parcelNo);
      if (resultSet?.goToFirstRow()) {
        detail = Parcel.fromResultSet(resultSet);
      }
      resultSet?.close();
    } catch (error) {
      Logger.error(TAG, `queryTemplateDetail failed. error: ${JSON.stringify(error)}`)
    }

    // 再查物流轨迹列表
    const condition1 = {
      field: 'parcel_number',
      value: parcelNo,
      operator: DBOperator.EQUAL,
    } as TablePredicate;
    const condition2 = {
      field: 'occurrence_time',
      operator: DBOperator.ORDER_BY_DESC,
    } as TablePredicate;
    let logisticResultSet = await rdbHelper.query('logistics', [condition1, condition2]);
    if (!logisticResultSet) {
      return {
        detail: detail,
        logs: [],
      } as ParcelWithLogistics;
    }
    let logisticsList: Logistics[] = [];
    try {
      while (logisticResultSet.goToNextRow()) {
        logisticsList.push(Logistics.fromResultSet(logisticResultSet));
      }
      logisticResultSet.close();
    } catch (error) {
      Logger.error(TAG, `query logistics List failed. error: ${JSON.stringify(error)}`)
    }

    return {
      detail: detail,
      logs: logisticsList,
    } as ParcelWithLogistics;
  }

  // 更新运单信息
  public async updateParcel(parcel: Parcel) {
    return rdbHelper.runTransaction(async () => {
      // 条件
      const condition = {
        field: 'parcel_number',
        value: parcel.parcelNumber,
        operator: DBOperator.EQUAL,
      } as TablePredicate;
      // 更新参数
      const valueBucket: relationalStore.ValuesBucket = {};
      if (parcel.expressCompany) {
        valueBucket.express_company = parcel.expressCompany;
      }
      if (parcel.senderName) {
        valueBucket.sender_name = parcel.senderName;
      }
      if (parcel.senderPhone) {
        valueBucket.sender_phone = parcel.senderPhone;
      }
      if (parcel.senderAddressId) {
        valueBucket.sender_address_id = parcel.senderAddressId;
      }
      if (parcel.senderFullAddress) {
        valueBucket.sender_full_address = parcel.senderFullAddress;
      }
      if (parcel.senderProvince) {
        valueBucket.sender_province = parcel.senderProvince;
      }
      if (parcel.senderCity) {
        valueBucket.sender_city = parcel.senderCity;
      }
      if (parcel.senderLatitude !== undefined) {
        valueBucket.sender_latitude = parcel.senderLatitude;
      }
      if (parcel.senderLongitude !== undefined) {
        valueBucket.sender_longitude = parcel.senderLongitude;
      }
      if (parcel.receiverName) {
        valueBucket.receiver_name = parcel.receiverName;
      }
      if (parcel.receiverPhone) {
        valueBucket.receiver_phone = parcel.receiverPhone;
      }
      if (parcel.receiverAddressId) {
        valueBucket.receiver_address_id = parcel.receiverAddressId;
      }
      if (parcel.receiverFullAddress) {
        valueBucket.receiver_full_address = parcel.receiverFullAddress;
      }
      if (parcel.receiverProvince) {
        valueBucket.receiver_province = parcel.receiverProvince;
      }
      if (parcel.receiverCity) {
        valueBucket.receiver_city = parcel.receiverCity;
      }
      if (parcel.receiverLatitude !== undefined) {
        valueBucket.receiver_latitude = parcel.receiverLatitude;
      }
      if (parcel.receiverLongitude !== undefined) {
        valueBucket.receiver_longitude = parcel.receiverLongitude;
      }
      if (parcel.price) {
        valueBucket.price = parcel.price;
      }
      if (parcel.paymentStatus) {
        valueBucket.payment_status = parcel.paymentStatus;
      }
      if (parcel.goodsName) {
        valueBucket.goods_name = parcel.goodsName;
      }
      if (parcel.weight) {
        valueBucket.weight = parcel.weight;
      }
      if (parcel.couponId !== undefined) {
        valueBucket.coupon_id = parcel.couponId;
      }
      if (parcel.pickupTime) {
        valueBucket.pickup_time = parcel.pickupTime;
      }
      if (parcel.payMethod !== undefined) {
        valueBucket.pay_method = parcel.payMethod;
      }
      if (parcel.updateTime) {
        valueBucket.update_time = parcel.updateTime;
      }
      if (parcel.cancelTime) {
        valueBucket.cancel_time = parcel.cancelTime;
      }
      if (parcel.deliveryTime) {
        valueBucket.delivery_time = parcel.deliveryTime;
      }
      if (parcel.estimatedArrivalTime) {
        valueBucket.estimated_arrival_time = parcel.estimatedArrivalTime;
      }
      if (parcel.grid) {
        valueBucket.grid = parcel.grid;
      }
      if (parcel.status) {
        valueBucket.status = parcel.status;
      }
      if (parcel.remark !== undefined) {
        valueBucket.remark = parcel.remark;
      }
      await rdbHelper.update(TABLE_NAME, valueBucket, [condition]);

      // 插入物流轨迹表
      const operatorInfo = STATUS_OPERATOR_MAP.get(parcel.status);
      let rowId = await LogisticsDB.createLogistics({
        parcelNumber: parcel.parcelNumber,
        occurrenceTime: parcel.updateTime,
        description: CommonUtil.handleDes(STATUS_DESCRIPTION_MAP.get(parcel.status), parcel),
        location: parcel.status > 3 ? parcel.receiverCity : parcel.senderCity,
        nodeStatus: parcel.status,
        operatorName: operatorInfo?.[0] || '',
        operatorPhone: operatorInfo?.[1] || '',
      } as Logistics);
      return rowId;
    })
  }

  // 删除运单
  public async deleteParcel(parcelNo: string) {
    const condition = {
      field: 'parcel_number',
      value: parcelNo,
      operator: DBOperator.EQUAL,
    } as TablePredicate

    const rowId = await rdbHelper.delete(TABLE_NAME, [condition]);
    return rowId > 0;
  }

  /**
   * 对比持久化数据与当前时间，自动补全物流轨迹
   */
  public async autoUpdateLogistics(parcel: Parcel): Promise<boolean> {
    const now = Date.now();
    const startTime = parcel.createTime;
    const timePassed = now - startTime;

    // 获取根据当前时间“应该”有的所有阶段
    const expectedStatus = RULES.filter((r) => timePassed >= r.offset)
      .sort((a, b) => a.offset - b.offset);
    // 需要去数据库查一下当前 logistics 表里已经存了多少条
    const currentTrackCount = await LogisticsDB.queryLogisticsCountByNumber(parcel.parcelNumber);
    // 如果应有的轨迹多于现有的，说明需要“补偿”插入
    const len = expectedStatus.length;
    if (expectedStatus.length > currentTrackCount) {
      for (let i = currentTrackCount; i < expectedStatus.length; i++) {
        const stage = expectedStatus[i];
        if (!stage) {
          continue;
        }
        if (i < len - 1) {
          // 执行持久化插入物流轨迹表
          const operatorInfo = STATUS_OPERATOR_MAP.get(parcel.status);

          await LogisticsDB.createLogistics({
            parcelNumber: parcel.parcelNumber,
            occurrenceTime: startTime + stage.offset, // 模拟过去发生的时间点
            description: CommonUtil.handleDes(STATUS_DESCRIPTION_MAP.get(stage.status), parcel),
            location: stage.status > 3 ? parcel.receiverCity : parcel.senderCity,
            nodeStatus: stage.status,
            operatorName: operatorInfo?.[0] || '',
            operatorPhone: operatorInfo?.[1] || '',
          } as Logistics);
        } else {
          // 同步更新主表状态为循环中最后一条的状态
          const data = {
            parcelNumber: parcel.parcelNumber,
            status: stage.status,
            updateTime: now,
            estimatedArrivalTime: parcel.createTime + 3600000 * 36,
          } as Parcel;
          // 寄付现结
          if (parcel.payMethod === PayMethod.PREPAID) {
            data.paymentStatus = PayStatus.PAID; // 已支付
          }
          if (stage.status === ParcelStatus.DELIVERED) {
            data.deliveryTime = parcel.createTime + 3600000 * 40;
            data.paymentStatus = PayStatus.PAID; // 已支付
          }
          const rowId = await this.updateParcel(data);
          return rowId > 0;
        }
      }
    }
    return false;
  }
}

const parcelDB = new ParcelDB();

export { parcelDB as ParcelDB };