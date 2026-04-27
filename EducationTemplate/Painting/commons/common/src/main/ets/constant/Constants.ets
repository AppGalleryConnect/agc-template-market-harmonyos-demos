// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  // 百分比类常量
  public static readonly FULL_SIZE: string = '100%';
  public static readonly NINETY_PERCENT: string = '90%';
  public static readonly EIGHTY_PERCENT: string = '80%';
  public static readonly SEVENTY_PERCENT: string = '70%';
  public static readonly SIXTY_PERCENT: string = '60%';
  public static readonly HALF_SIZE: string = '50%';
  public static readonly FORTY_PERCENT: string = '40%';
  public static readonly THIRTY_PERCENT: string = '30%';
  public static readonly TWENTY_PERCENT: string = '20%';
  public static readonly QUARTER_SIZE: string = '25%';
  public static readonly THREE_QUARTERS_SIZE: string = '75%';
  public static readonly TEN_PERCENT: string = '10%';

  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;

}

