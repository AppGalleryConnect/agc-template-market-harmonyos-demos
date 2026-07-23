import { ValueType } from '@kit.ArkData';

export enum DBOperator {
  EQUAL,
  NOT_EQUAL,
  GREATER,
  GREATER_OR_EQUAL,
  LESS,
  LESS_OR_EQUAL,
  LIKE,
  IS_NULL,
  IS_NOT_NULL,
  BEGIN_WITH,
  END_WITH,
  CONTAIN,
  ORDER_BY_DESC,
  ORDER_BY_ASC,
}

export enum DBOperationErrorCode {
  NO_STORE = -100,
  INSERT_ERROR = -101,
  UPDATE_ERROR = -102,
  DELETE_ERROR = -103,
  QUERY_ERROR = -104,
}

export interface TableSchema {
  tableName: string;
  createSQL: string;
  indexes?: string[];
}

export interface TablePredicate {
  field: string;
  value: ValueType;
  operator: DBOperator;
}
