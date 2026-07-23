import { relationalStore, ValueType } from '@kit.ArkData';
import { DBOperationErrorCode, DBOperator, TablePredicate, TableSchema } from '../constants/Constants';
import { Logger } from '../utils/Logger';


const TAG = '[RdbHelper]';

// 数据库操作类
export class RdbHelper {
  private static instance: RdbHelper;
  private static rdbStore: relationalStore.RdbStore | null = null;
  public static dbConfig: relationalStore.StoreConfig = {
    name: 'ImageProcessing.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  public tableSchema: TableSchema | null = null;

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper()
    }
    return RdbHelper.instance
  }

  // 初始化数据库
  public static async initDB(context: Context) {
    try {
      RdbHelper.rdbStore = await relationalStore.getRdbStore(context, RdbHelper.dbConfig);
      Logger.info(TAG, `[${RdbHelper.dbConfig.name}] database initialized success`);
    } catch (err) {
      Logger.error(
        TAG,
        `database initialized failed. error: ${JSON.stringify(err)}`,
      );
    }
  }

  // 创建表结构
  public async createTables(tableSchema: TableSchema) {
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
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  public getStore(): relationalStore.RdbStore {
    if (!RdbHelper.rdbStore) {
      throw new Error('RdbStore is not initialized. Please call initDb first.')
    }
    return RdbHelper.rdbStore
  }

  // 创建事务
  public async runTransaction(callback: () => Promise<number>): Promise<number> {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `beginTransaction failed: rdbStore is null`);
      return -1;
    }

    try {
      RdbHelper.rdbStore.beginTransaction(); // 开启
      const result = await callback();
      // 关键逻辑：如果回调逻辑返回了 -1（代表业务失败），手动触发回滚
      if (result === -1) {
        Logger.error(TAG, `Callback returned -1, rolling back...`);
        RdbHelper.rdbStore.rollBack(); // 注意拼写是否为 rollback
        return -1;
      }
      RdbHelper.rdbStore.commit(); // 提交
      return result;
    } catch (error) {
      // 打印原始错误堆栈，不要只用 JSON.stringify，有时抓不到 stack
      Logger.error(TAG, `Transaction failed. Error: ${error.message || JSON.stringify(error)}`);
      // 确保回滚
      if (RdbHelper.rdbStore) {
        RdbHelper.rdbStore.rollBack();
      }
      return -1;
    }
  }

  // 通用插入方法
  public async insert<T>(tableName: string, values: T, conflict?: relationalStore.ConflictResolution) {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `no database rdbStore`);
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      if (conflict) {
        return await RdbHelper.rdbStore.insert(
          tableName,
          values as relationalStore.ValuesBucket,
          conflict
        );
      }
      return await RdbHelper.rdbStore.insert(
        tableName,
        values as relationalStore.ValuesBucket
      );

    } catch (err) {
      Logger.error(TAG, `database insert failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.INSERT_ERROR;
    }
  }

  // 插入多个
  public async batchInsert<T>(tableName: string, values: T[]) {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `no database rdbStore`);
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      return await RdbHelper.rdbStore.batchInsert(
        tableName,
        values as relationalStore.ValuesBucket[],
      );
    } catch (err) {
      Logger.error(TAG, `database insert failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.INSERT_ERROR;
    }
  }

  // 通用查询方法
  public async query(tableName: string, conditions: TablePredicate[]) {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `no database rdbStore`);
      return undefined;
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.query(predicates);
    } catch (err) {
      Logger.error(TAG, `database query failed. error: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  // 根据谓词查询
  public async queryByPredicates(predicates: relationalStore.RdbPredicates) {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `no database rdbStore`);
      return undefined;
    }

    try {
      return await RdbHelper.rdbStore.query(predicates);
    } catch (err) {
      Logger.error(TAG, `database query failed. error: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  // 通用更新方法
  public async update<T>(
    tableName: string,
    values: T,
    conditions: TablePredicate[],
  ): Promise<number> {
    if (!RdbHelper.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.update(
        values as relationalStore.ValuesBucket,
        predicates,
      );
    } catch (err) {
      Logger.error(
        TAG,
        `database update failed. error: ${JSON.stringify(err)}`,
      );
      return DBOperationErrorCode.UPDATE_ERROR;
    }
  }

  // 通用删除方法
  public async delete(
    tableName: string,
    conditions: TablePredicate[],
  ): Promise<number> {
    if (!RdbHelper.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }
    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await RdbHelper.rdbStore.delete(predicates);
    } catch (err) {
      Logger.error(TAG, `database delete failed. error: ${JSON.stringify(err)}`);
      return DBOperationErrorCode.DELETE_ERROR;
    }
  }

  public async querySql(sql: string, args: ESObject) {
    if (!RdbHelper.rdbStore) {
      Logger.error(TAG, `no database rdbStore`);
      return undefined;
    }

    try {
      const result = await RdbHelper.rdbStore.querySql(sql, Array.isArray(args) ? args : [args]);
      return result;
    } catch (err) {
      Logger.error(TAG, `database query sql failed. error: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  public async executeSql(sql: string, args?: Array<ValueType>): Promise<void> {
    if (!RdbHelper.rdbStore) {
      return;
    }

    try {
      await RdbHelper.rdbStore.executeSql(sql, args);
    } catch (err) {
      Logger.error(
        TAG,
        `database query sql failed. error: ${JSON.stringify(err)}`,
      );
    }
  }

  private _buildPredicates(
    tableName: string,
    conditions: TablePredicate[],
  ): relationalStore.RdbPredicates {
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
        default:
          break;
      }
    });
    return predicates;
  }
}

export const rdbHelper = RdbHelper.getInstance();