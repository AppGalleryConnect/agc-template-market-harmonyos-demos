/**
 * 业务options模型
 */
export interface BreakpointTypeOptions<T> {
  [BreakpointNameEnum.SM]?: T,
  [BreakpointNameEnum.MD]?: T,
  [BreakpointNameEnum.LG]?: T,
  [BreakpointNameEnum.XL]?: T,
}

/**
 * 业务options类
 */
export class BreakpointType<T> {
  private options: BreakpointTypeOptions<T>;

  constructor(options: BreakpointTypeOptions<T>) {
    this.options = options;
  }

  // 通过bp的值从this.options中获取对应的属性值。
  public getValue(bp: BreakpointNameEnum) {
    return Reflect.get(this.options, bp) as T;
  }
}

/**
 * 断点名称
 */
export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

/**
 * 断点取值
 */
export enum BreakpointValueEnum {
  SM = '600vp',
  MD = '840vp',
  LG = '1440vp',
}

/**
 * 栅格通用设置
 */
export class GridRowColSetting {
  /**
   * 栅格布局-断点数列
   */
  public static readonly BREAK_POINT_VALUE: string[] =
    ['0', BreakpointValueEnum.SM, BreakpointValueEnum.MD, BreakpointValueEnum.LG];
  /**
   * 栅格布局-列数
   */
  public static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  }
  /**
   * 栅格布局-x间距
   */
  public static readonly GRID_ROW_OPTIONS_GUTTER_X: GridRowSizeOption = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
  }
  /**
   * 搜索词条最大宽度栅格列数
   */
  public static readonly GRID_MAX_COLUMNS: GridRowSizeOption = {
    sm: 2,
    md: 3,
    lg: 4,
    xl: 4,
  }
  /**
   * 搜索词条最大宽度栅格间隔
   */
  public static readonly GRID_MAX_GUTTER: GridRowSizeOption = {
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  }
  /**
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };
  /**
   * 猜你想搜列数
   */
  public static readonly COLUMNS_GUESS_LIKE: GridRowColumnOption = {
    sm: 2,
    md: 3,
    lg: 3,
    xl: 3,
  };
  /**
   * 猜你想搜间距
   */
  public static readonly SPACE_GUESS_LIKE: GridRowColumnOption = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 16,
  };
  /**
   * 热搜榜列数
   */
  public static readonly COLUMNS_HOT_SEARCH: GridRowColumnOption = {
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  };
  /**
   * 搜索结果间隔
   */
  public static readonly COLUMNS_SEARCH_RESULT: GridRowColumnOption = {
    sm: 0,
    md: 12,
    lg: 24,
    xl: 24,
  };

  /**
   * 栅格行布局容器-默认参数
   */
  public static readonly DEFAULT_GRID_ROW_OPTIONS: GridRowOptions = {
    gutter: {
      x: GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X,
    },
    columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
    breakpoints: {
      value: GridRowColSetting.BREAK_POINT_VALUE,
      reference: BreakpointsReference.WindowSize,
    },
    direction: GridRowDirection.Row,
  };
  /**
   * 弹窗最大宽度
   */
  public static readonly DIALOG_MAX_WIDTH: number = 400;
  /**
   * 获取窗口断点栅格数
   * @param bp
   * @returns
   */
  public static getWindowColumn(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, bp);
  }
  /**
   * 获取栅格布局-x间距
   * @param bp
   * @returns
   */
  public static getGutter(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X, bp);
  }
  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp);
  }
  /**
   * 获取猜你想搜列数
   * @param bp
   * @returns
   */
  public static getGuessLikeColumn(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.COLUMNS_GUESS_LIKE, bp);
  }
  /**
   * 获取猜你想搜间隔
   * @param bp
   * @returns
   */
  public static getGuessLikeSpace(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.SPACE_GUESS_LIKE, bp);
  }
  /**
   * 获取搜索结果间隔
   * @param bp
   * @returns
   */
  public static getSearchResultSpace(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.COLUMNS_SEARCH_RESULT, bp);
  }
  /**
   * 获取热搜榜、搜索结果列数
   * @param bp
   * @returns
   */
  public static getShowResult(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.COLUMNS_HOT_SEARCH, bp);
  }
  /**
   * 搜索词条最大宽度栅格列数
   * @param bp
   * @returns
   */
  public static getMaxColumns(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_MAX_COLUMNS, bp);
  }
  /**
   * 搜索词条最大宽度栅格间隔
   * @param bp
   * @returns
   */
  public static getMaxGutter(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_MAX_GUTTER, bp);
  }
}