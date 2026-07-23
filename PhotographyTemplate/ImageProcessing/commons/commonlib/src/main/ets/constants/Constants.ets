import { ValueType } from '@kit.ArkData';

export class CommonConstants {
  // todo 网络请求base url，真实网络请求可以替换请求地址
  public static readonly BASE_URL = '';
  // Space
  static readonly SPACE_XXS: number = 2;
  static readonly SPACE_XS: number = 4;
  static readonly SPACE_S: number = 8;
  static readonly SPACE_M: number = 12;
  static readonly SPACE_L: number = 16;
  static readonly SPACE_XL: number = 20;
  static readonly SPACE_XXL: number = 24;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  // Padding
  static readonly PADDING_XXS: number = 2;
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_XL: number = 20;
  static readonly PADDING_XXL: number = 24;
  static readonly PADDING_PAGE: number = 16;
  // 颜色
  static readonly COLOR_LIST: string[] =
    ['#000000', '#FFFFFF', '#E52424', '#E56224', '#F6C800', '#63B959', '#48ADDD', '#5445EF', '#A946F1'];
}

/**
 * 数据库操作
 */
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
}

/**
 * 数据库错误码
 */
export enum DBOperationErrorCode {
  NO_STORE = -100,
  INSERT_ERROR = -101,
  UPDATE_ERROR = -102,
  DELETE_ERROR = -103,
  QUERY_ERROR = -104,
}

// 表结构定义类型
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