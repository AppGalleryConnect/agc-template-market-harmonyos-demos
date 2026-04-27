import { relationalStore } from '@kit.ArkData';
import { Logger } from '../Logger';
import { DBOperationErrorCode, DBOperator } from './Constants';
import {
  TableOrderByParams,
  TablePredicateParams,
  TableQueryWithPaginationRsp,
  TableSchema,
} from './Types';

const TAG = '[BaseDB]';

// 基础数据库操作类
export abstract class BaseDB {
  protected rdbStore: relationalStore.RdbStore | null = null;
  protected abstract dbConfig: relationalStore.StoreConfig;
  protected abstract tableSchemas: TableSchema[];

  // 初始化数据库
  public async initialize(context: Context) {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.dbConfig);
      await this._createTables();
      Logger.info(TAG, `[${this.dbConfig.name}] database initialized success`);
    } catch (err) {
      Logger.error(
        TAG,
        `database initialized failed. error: ${JSON.stringify(err)}`,
      );
    }
  }

  // 创建表结构
  private async _createTables() {
    if (!this.rdbStore) {
      return;
    }
    try {
      for (const schema of this.tableSchemas) {
        await this.rdbStore.executeSql(schema.createSQL);
        if (schema.indexes) {
          for (const indexSQL of schema.indexes) {
            await this.rdbStore.executeSql(indexSQL);
          }
        }
      }
    } catch (err) {
      Logger.error(TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  // 通用插入方法
  protected async insert<T>(tableName: string, values: T): Promise<number> {
    if (!this.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      return await this.rdbStore.insert(
        tableName,
        values as relationalStore.ValuesBucket,
      );
    } catch (err) {
      Logger.error(
        TAG,
        `database insert failed. error: ${JSON.stringify(err)}`,
      );
      return DBOperationErrorCode.INSERT_ERROR;
    }
  }

  // 通用更新方法
  protected async update<T>(
    tableName: string,
    values: T,
    conditions: TablePredicateParams[],
  ): Promise<number> {
    if (!this.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await this.rdbStore.update(
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
  protected async delete(
    tableName: string,
    conditions: TablePredicateParams[],
  ): Promise<number> {
    if (!this.rdbStore) {
      return DBOperationErrorCode.NO_STORE;
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      return await this.rdbStore.delete(predicates);
    } catch (err) {
      Logger.error(
        TAG,
        `database delete failed. error: ${JSON.stringify(err)}`,
      );
      return DBOperationErrorCode.DELETE_ERROR;
    }
  }

  // 通用查询方法
  protected async query<T>(
    tableName: string,
    conditions: TablePredicateParams[],
    orderBy?: TableOrderByParams,
    limit?: number,
  ): Promise<T[]> {
    if (!this.rdbStore) {
      return [];
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      if (orderBy) {
        if (orderBy.desc) {
          predicates.orderByDesc(orderBy.field);
        }
        predicates.orderByAsc(orderBy.field);
      }
      if (limit) {
        predicates.limitAs(limit);
      }

      const result = await this.rdbStore.query(predicates);
      const items: T[] = [];
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        items.push(result.getRow() as T);
      }
      return items;
    } catch (err) {
      Logger.error(TAG, `database query failed. error: ${JSON.stringify(err)}`);
      return [];
    }
  }

  protected async querySql<T>(sql: string): Promise<T[]> {
    if (!this.rdbStore) {
      return [];
    }

    try {
      const result = await this.rdbStore.querySql(sql);
      const items: T[] = [];
      for (let i = 0; i < result.rowCount; i++) {
        result.goToRow(i);
        items.push(result.getRow() as T);
      }
      return items;
    } catch (err) {
      console.error(
        TAG,
        `database query sql failed. error: ${JSON.stringify(err)}`,
      );
      return [];
    }
  }

  protected async executeSql(sql: string): Promise<void> {
    if (!this.rdbStore) {
      return;
    }

    try {
      await this.rdbStore.executeSql(sql);
    } catch (err) {
      console.error(
        TAG,
        `database query sql failed. error: ${JSON.stringify(err)}`,
      );
    }
  }

  protected async count(
    tableName: string,
    conditions: TablePredicateParams[] = [],
  ): Promise<number> {
    if (!this.rdbStore) {
      return 0;
    }

    try {
      const predicates = this._buildPredicates(tableName, conditions);
      const result = await this.rdbStore.query(predicates, [
        'COUNT(*) AS total',
      ]);
      if (result.rowCount) {
        result.goToRow(0);
        const total = result.getRow().total as number;
        return total;
      }
      return 0;
    } catch (err) {
      console.error(`统计记录失败: ${JSON.stringify(err)}`);
      return 0;
    }
  }

  protected async queryWithPagination<T>(
    tableName: string,
    conditions: TablePredicateParams[],
    page: number,
    pageSize: number,
    orderBy?: TableOrderByParams,
  ): Promise<TableQueryWithPaginationRsp<T>> {
    // 参数校验
    page = page < 1 ? 1 : page;
    pageSize = pageSize < 1 ? 10 : pageSize;

    try {
      const total = await this.count(tableName, conditions);
      const predicates = this._buildPredicates(tableName, conditions);

      if (orderBy) {
        if (orderBy.desc) {
          predicates.orderByDesc(orderBy.field);
        }
        predicates.orderByAsc(orderBy.field);
      }
      predicates.limitAs(pageSize).offsetAs((page - 1) * pageSize);

      const result = await this.rdbStore?.query(predicates);
      const data: T[] = [];
      if (result) {
        for (let i = 0; i < result.rowCount; i++) {
          result.goToRow(i);
          data.push(result.getRow() as T);
        }
      }

      return { data, total };
    } catch (err) {
      console.error(
        TAG,
        `database query with pagination failed. error: ${JSON.stringify(err)}`,
      );
      return { data: [], total: 0 };
    }
  }

  // 事务处理
  protected async transaction<T>(callback: () => Promise<T>): Promise<T> {
    if (!this.rdbStore) {
      throw new Error(`${TAG}, database has not been initialized`);
    }

    try {
      this.rdbStore.beginTransaction();
      const result = await callback();
      this.rdbStore.commit();
      return result;
    } catch (err) {
      this.rdbStore.rollBack();
      const errMsg = `${TAG} database start transaction failed. error: ${JSON.stringify(err)}`;
      throw new Error(errMsg);
    }
  }

  private _buildPredicates(
    tableName: string,
    conditions: TablePredicateParams[],
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
        default:
          break;
      }
    });
    return predicates;
  }
}
