import { UtilLog } from '@hw-agconnect/util-log';
import { relationalStore, ValueType } from '@kit.ArkData';
import { DBOperationErrorCode, DBOperator, TablePredicate, TableSchema } from './DBConstants';

const TAG = '[CalendarRdbHelper]';
const DOMAIN = 0x0001;

export class RdbHelper {
  private static rdbStore: relationalStore.RdbStore | null = null;
  private static instance: RdbHelper | null = null;
  private static initPromise: Promise<boolean> | null = null;

  public static readonly dbConfig: relationalStore.StoreConfig = {
    name: 'CalendarEvent.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };

  private constructor() {}

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  public static async initDB(context: Context): Promise<boolean> {
    if (RdbHelper.rdbStore) {
      return true;
    }
    if (RdbHelper.initPromise) {
      return RdbHelper.initPromise;
    }
    RdbHelper.initPromise = RdbHelper.getInstance()._initStore(context);
    return RdbHelper.initPromise;
  }

  private async _initStore(context: Context): Promise<boolean> {
    try {
      RdbHelper.rdbStore = await relationalStore.getRdbStore(context, RdbHelper.dbConfig);
      UtilLog.info(DOMAIN, TAG, `database initialized success`);
      return true;
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database initialized failed. error: ${JSON.stringify(err)}`);
      return false;
    }
  }

  public async createTables(tableSchema: TableSchema): Promise<void> {
    if (!RdbHelper.rdbStore || !tableSchema) {
      return;
    }
    try {
      await RdbHelper.rdbStore.executeSql(tableSchema.createSQL);
      if (tableSchema.indexes) {
        for (const indexSQL of tableSchema.indexes) {
          await RdbHelper.rdbStore.executeSql(indexSQL);
        }
      }
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  public getStore(): relationalStore.RdbStore {
    if (!RdbHelper.rdbStore) {
      throw new Error('RdbStore is not initialized. Please call initDB first.');
    }
    return RdbHelper.rdbStore;
  }

  public async insert<T>(tableName: string, values: T,
    conflict?: relationalStore.ConflictResolution): Promise<number> {
    if (!RdbHelper.rdbStore) {
      UtilLog.error(DOMAIN, TAG, `no database rdbStore`);
      return DBOperationErrorCode.NO_STORE;
    }
    try {
      if (conflict) {
        return await RdbHelper.rdbStore.insert(tableName, values as relationalStore.ValuesBucket, conflict);
      }
      return await RdbHelper.rdbStore.insert(tableName, values as relationalStore.ValuesBucket);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database insert failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.INSERT_ERROR;
    }
  }

  public async batchInsert<T>(tableName: string, valuesList: T[]): Promise<number> {
    if (!RdbHelper.rdbStore) {
      UtilLog.error(DOMAIN, TAG, `no database rdbStore`);
      return DBOperationErrorCode.NO_STORE;
    }
    if (!valuesList || valuesList.length === 0) {
      return 0;
    }
    try {
      const valuesBuckets = valuesList.map(v => v as relationalStore.ValuesBucket);
      return await RdbHelper.rdbStore.batchInsert(tableName, valuesBuckets);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database batch insert failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.INSERT_ERROR;
    }
  }

  public async query(tableName: string, conditions: TablePredicate[]): Promise<
    relationalStore.ResultSet | undefined> {
    if (!RdbHelper.rdbStore) {
      UtilLog.error(DOMAIN, TAG, `no database rdbStore`);
      return undefined;
    }
    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.query(predicates);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database query failed. error: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  public async querySql(sql: string, args?: Array<ValueType>): Promise<
    relationalStore.ResultSet | undefined> {
    if (!RdbHelper.rdbStore) {
      UtilLog.error(DOMAIN, TAG, `no database rdbStore`);
      return undefined;
    }
    try {
      return await RdbHelper.rdbStore.querySql(sql, args);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database querySql failed. error: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  public async update<T>(tableName: string, values: T,
    conditions: TablePredicate[]): Promise<number> {
    if (!RdbHelper.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }
    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.update(values as relationalStore.ValuesBucket, predicates);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database update failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.UPDATE_ERROR;
    }
  }

  public async delete(tableName: string, conditions: TablePredicate[]): Promise<number> {
    if (!RdbHelper.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }
    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.delete(predicates);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database delete failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.DELETE_ERROR;
    }
  }

  public async executeSql(sql: string, args?: Array<ValueType>): Promise<void> {
    if (!RdbHelper.rdbStore) {
      return;
    }
    try {
      await RdbHelper.rdbStore.executeSql(sql, args);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `database executeSql failed. error: ${JSON.stringify(err)}`);
    }
  }

  private _buildPredicates(tableName: string, conditions: TablePredicate[]): relationalStore.RdbPredicates {
    const predicates = new relationalStore.RdbPredicates(tableName);
    conditions.forEach((cond) => {
      switch (cond.operator) {
        case DBOperator.EQUAL:
          predicates.equalTo(cond.field, cond.value);
          break;
        case DBOperator.NOT_EQUAL:
          predicates.notEqualTo(cond.field, cond.value);
          break;
        case DBOperator.GREATER:
          predicates.greaterThan(cond.field, cond.value);
          break;
        case DBOperator.GREATER_OR_EQUAL:
          predicates.greaterThanOrEqualTo(cond.field, cond.value);
          break;
        case DBOperator.LESS:
          predicates.lessThan(cond.field, cond.value);
          break;
        case DBOperator.LESS_OR_EQUAL:
          predicates.lessThanOrEqualTo(cond.field, cond.value);
          break;
        case DBOperator.LIKE:
          predicates.like(cond.field, cond.value as string);
          break;
        case DBOperator.IS_NULL:
          predicates.isNull(cond.field);
          break;
        case DBOperator.IS_NOT_NULL:
          predicates.isNotNull(cond.field);
          break;
        case DBOperator.BEGIN_WITH:
          predicates.beginsWith(cond.field, cond.value as string);
          break;
        case DBOperator.END_WITH:
          predicates.endsWith(cond.field, cond.value as string);
          break;
        case DBOperator.CONTAIN:
          predicates.contains(cond.field, cond.value as string);
          break;
        case DBOperator.ORDER_BY_DESC:
          predicates.orderByDesc(cond.field);
          break;
        case DBOperator.ORDER_BY_ASC:
          predicates.orderByAsc(cond.field);
          break;
        default:
          break;
      }
    });
    return predicates;
  }
}

export const rdbHelper = RdbHelper.getInstance();
