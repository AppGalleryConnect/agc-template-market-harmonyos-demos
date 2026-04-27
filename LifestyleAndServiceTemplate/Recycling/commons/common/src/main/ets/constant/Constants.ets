// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  public static readonly FULL_SIZE = '100%';

  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  // Padding
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_XL: number = 20;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_2XL: number = 24;
  static readonly PADDING_5XL: number = 36;
  static readonly PADDING_6XL: number = 40;
  static readonly PADDING_3XL: number = 28;
  static readonly PADDING_4XL: number = 32;
  static readonly PADDING_7XL: number = 44;
}

