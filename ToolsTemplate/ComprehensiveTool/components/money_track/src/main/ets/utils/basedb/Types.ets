import { ValueType } from '@kit.ArkData';
import { DBOperator } from './Constants';

// 表结构定义类型
export interface TableSchema {
  tableName: string;
  createSQL: string;
  indexes?: string[];
}

export interface TablePredicateParams {
  field: string;
  value: ValueType;
  operator: DBOperator;
}

export interface TableOrderByParams {
  field: string;
  desc?: boolean;
}

export interface TableQueryWithPaginationRsp<T> {
  data: T[];
  total: number;
}
