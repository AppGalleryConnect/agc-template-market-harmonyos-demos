
export class CommonConstants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Operator Collection.
   */
  static readonly OPERATORS: string = '+-×÷';

  /**
   * Operators with high precedence.
   */
  static readonly OPERATORS_PRIORITY: string = '×÷';

  /**
   * Addition.
   */
  static readonly ADD: string = '+';

  /**
   * Minus.
   */
  static readonly MIN: string = '-';

  /**
   * Multiplication.
   */
  static readonly MUL: string = '×';

  /**
   * Division.
   */
  static readonly DIV: string = '÷';

  /**
   * Percent sign.
   */
  static readonly PERCENT_SIGN: string = '%';

  /**
   * Decimal point.
   */
  static readonly DOTS: string = '.';

  /**
   * Number two.
   */
  static readonly TWO: number = 2;

  /**
   * Digit ten.
   */
  static readonly TEN: number = 10;

  /**
   * One hundred.
   */
  static readonly ONE_HUNDRED: string = '100';

  /**
   * Display Maximum Length of Large Fonts.
   */
  static readonly INPUT_LENGTH_MAX: number = 9;

  /**
   * Subscript is two.
   */
  static readonly INDEX_TWO: number = 2;

  /**
   * Maximum length of a single digit.
   */
  static readonly NUM_MAX_LEN: number = 16;

  /**
   * Letter e.
   */
  static readonly E: string = 'e';

  /**
   * String Zero.
   */
  static readonly ZERO: string = '0'

  /**
   * zero point.
   */
  static readonly ZERO_DOTS: string = '0.'
  // 下载缓存文件夹
  static readonly STORAGE_CACHE_PATH: string = 'cache_path';

}

/**
 * Symbol value.
 */
export enum Symbol {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷',
  CLEAN = 'C',
  DEL = 'del',
  EQU = '='
}

/**
 * Operator Precedence Enumeration.
 */
export enum Priority {
  HIGH = 2,
  MEDIUM = 1,
  LOW = 0
}

/**
 * Enumerated value: addition, subtraction, multiplication, and division.
 */
export enum SymbolicEnumeration {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷'
}

export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)
