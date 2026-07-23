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
   * 居中8栅格列span
   */
  public static readonly DEFAULT_CENTER_COL_SPAN: GridColColumnOption = {
    sm: 4,
    md: 8,
    lg: 8,
    xl: 8,
  };
  /**
   * 居中8栅格列offset
   */
  public static readonly DEFAULT_CENTER_COL_OFFSET: GridColColumnOption = {
    sm: 0,
    md: 0,
    lg: 2,
    xl: 2,
  };
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
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
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
   * 栅格行布-按钮边距
   */
  public static readonly BUTTON_GUTTER: GridRowColumnOption = {
    sm: 8,
    md: 12,
    lg: 12,
    xl: 12,
  }
  /**
   * 网格列数-columnsNum
   */
  public static readonly COLUMNS_NUM: GridRowColumnOption = {
    sm: 2,
    md: 4,
    lg: 6,
    xl: 6,
  };

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
   * 获取按钮边距
   * @param bp
   * @returns
   */
  public static getButtonGutter(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.BUTTON_GUTTER, bp);
  }


  /**
   * 获取网格列数
   * @param bp
   * @returns
   */
  public static getColumnsNum(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.COLUMNS_NUM, bp);
  }
}