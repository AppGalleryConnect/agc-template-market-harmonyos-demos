/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export const enum CalculatorType {
  // 标准计算器
  StandardCalc,
  // 科学计算器
  ScienceCalc,
  // 分数计算器
  FractionCalc
}

export const enum BUTTON_TYPE {
  // 数字
  NUMBER,
  // 图片
  ICON,
  // 字母
  LETTERS,
}

/**
 * Common constants for all features.
 */
export class CalcConstants {
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

  static readonly OPERATORS_ARY: Array<string> = ['+', '-', '×', '÷']

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

  /*
   * 字体大小
   * */
  static readonly  FONT_SIZE_12 = 12;
  static readonly  FONT_SIZE_16 = 16;
  static readonly  FONT_SIZE_20 = 20;
  static readonly  FONT_SIZE_24 = 24;
  static readonly  FONT_SIZE_32 = 32;

  /*
   * 字体粗细
   * */
  static readonly  FONT_WEIGHT_MEDIUM = FontWeight.Medium;
  static readonly  FONT_WEIGHT_REGULAR = FontWeight.Regular;
  static readonly  FONT_WEIGHT_LIGHTER = FontWeight.Lighter;
  static readonly  FONT_WEIGHT_BOLD = FontWeight.Bold;
  static readonly  FONT_WEIGHT_BOLDER = FontWeight.Bolder;
  static readonly  FONT_WEIGHT_SEMIBOLD = 'SemiBold';

  /*
   * 字体格式
   * */
  static readonly FONT_FAMILY_1 = '鸿蒙黑体'

  /*
   * 组件间隔
   * */
  static readonly  COMPONENT_BAY_SIZE_4 = 4;
  static readonly  COMPONENT_BAY_SIZE_8 = 8;
  static readonly  COMPONENT_BAY_SIZE_16 = 16;
  static readonly  COMPONENT_BAY_SIZE_36 = 36;

  /*
   * 圆角
   * */
  static readonly  BORDER_RADIUS_0 = 0;
  static readonly  BORDER_RADIUS_16 = 16;
  static readonly  BORDER_RADIUS_20 = 20;

  /*
   * 组件宽
   * */
  static readonly WIDTH_36 = 36
  static readonly WIDTH_98 = 98
  static readonly WIDTH_99 = 99
  static readonly WIDTH_296 = 296

  /*
   * 组件高
   * */
  static readonly HEIGHT_20 = 20
  static readonly HEIGHT_79 = 79
  static readonly HEIGHT_80 = 80
  static readonly HEIGHT_320 = 320

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
export enum AppStorageMap {
  HISTORY_RESULT = 'historyResult',
}