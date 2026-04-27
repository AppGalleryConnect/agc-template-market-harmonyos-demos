

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
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };

  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: BreakpointNameEnum): number {
    // Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp),
    // 针对部分手机机型会报错：Error message:Reflect.has target is not object
    return GridRowColSetting.GRID_ROW_OPTIONS_MARGIN[bp] ?? 16
  }

  /**
   * 根据栅格化动态获取列表数量
   * @returns
   */
  public static getColumnCount(): number {

    return 2
  }
}
