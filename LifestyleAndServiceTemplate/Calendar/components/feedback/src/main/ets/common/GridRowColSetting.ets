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
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };
  /**
   * 栅格布局-padding
   */
  public static readonly GRID_ROW_OPTIONS_PADDING: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 0,
    xl: 0,
  };
  /**
   * 问题反馈图片宫格数量
   */
  public static readonly COLUMNS_NUM: GridRowColumnOption = {
    sm: 3,
    md: 6,
    lg: 6,
    xl: 6,
  };
  /**
   * 问题记录瀑布流列数
   */
  public static readonly WATER_FLOW_COLUMNS: GridRowColumnOption = {
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
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
   * 按钮最大宽度
   */
  public static readonly DIALOG_BUTTON_WIDTH: number = 448;

  /**
   * 获取页面padding
   * @param bp
   * @returns
   */
  public static getPagePadding(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_PADDING, bp);
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
   * 获取图片间隔
   * @param bp
   * @returns
   */
  public static getGutter(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X, bp);
  }

  /**
   * 获取宫格数量
   * @param bp
   * @returns
   */
  public static getGridNum(bp: BreakpointNameEnum | string): string {
    return Array(Reflect.get(GridRowColSetting.COLUMNS_NUM, bp)).fill('1fr').join(' ');
  }

  /**
   * 获取瀑布流列数
   * @param bp
   * @returns
   */
  public static getWaterFloColumns(bp: BreakpointNameEnum | string): string {
    return Array(Reflect.get(GridRowColSetting.WATER_FLOW_COLUMNS, bp)).fill('1fr').join(' ');
  }
}


