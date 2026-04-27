/**
 * 栅格通用设置
 */
export class GridRowColSetting {
  /**
   * 栅格布局-断点数列
   */
  public static readonly BREAK_POINT_VALUE: string[] = ['0', '600vp', '840vp', '1440vp'];
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
   * 栅格布局-列数
   */
  public static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    sm: 4,
    lg: 12,
    xl: 12,
    md: 8,
  }
  /**
   * 栅格行布局容器-默认参数
   */
  public static readonly DEFAULT_GRID_ROW_OPTIONS: GridRowOptions = {
    columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
    gutter: {
      x: GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X,
    },
    direction: GridRowDirection.Row,
    breakpoints: {
      value: GridRowColSetting.BREAK_POINT_VALUE,
      reference: BreakpointsReference.WindowSize,
    },
  };
  /**
   * 居中8栅格列offset
   */
  public static readonly DEFAULT_CENTER_COL_OFFSET: GridColColumnOption = {
    sm: 0,
    lg: 2,
    xl: 2,
    md: 0,
  };
  /**
   * 居中8栅格列span
   */
  public static readonly DEFAULT_CENTER_COL_SPAN: GridColColumnOption = {
    sm: 4,
    lg: 8,
    xl: 8,
    md: 8,
  };

  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp);
  }
}
