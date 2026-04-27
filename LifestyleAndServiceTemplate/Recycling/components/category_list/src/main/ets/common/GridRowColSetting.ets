import { DeviceUtils, GlobalContext } from 'common';

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
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };
  public static readonly TITLE_COL_SPAN: GridColColumnOption = {
    sm: 1,
    md: 2,
    lg: 2,
    xl: 2,
  };
  public static readonly SUBTITLE_COL_SPAN: GridColColumnOption = {
    sm: 3,
    md: 6,
    lg: 10,
    xl: 10,
  };
  public static readonly TAB_MARGIN: GridColColumnOption = {
    sm: 0,
    md: 24,
    lg: 32,
    xl: 32,
  };
  /**
   * 网格列数-columnsNum
   */
  public static readonly COLUMNS_NUM: GridRowColumnOption = {
    sm: 2,
    md: 4,
    lg: 8,
    xl: 8,
  };
  /**
   * 列表列数-columnsNum
   */
  public static readonly LIST_NUM: GridRowColumnOption = {
    sm: 1,
    md: 2,
    lg: 4,
    xl: 4,
  };
  /**
   * 栅格行布局容器-默认参数
   */
  public static readonly DEFAULT_GRID_ROW_OPTIONS: GridRowOptions = {
    gutter: {
      x: 12,
      y: 16,
    },
    columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
    breakpoints: {
      value: GridRowColSetting.BREAK_POINT_VALUE,
      reference: BreakpointsReference.WindowSize,
    },
    direction: GridRowDirection.Row,
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
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp);
  }

  /**
   * 获取网格列数
   * @param bp
   * @returns
   */
  public static getColumnsNum(bp: BreakpointNameEnum | string): string {
    return Array(Reflect.get(GridRowColSetting.COLUMNS_NUM, bp)).fill('1fr').join(' ');
  }

  /**
   * 获取列表列数
   * @param bp
   * @returns
   */
  public static getListNum(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.LIST_NUM, bp);
  }

  /**
   * 获取标题栏间距
   * @param bp
   * @returns
   */
  public static getTabMargin(bp: BreakpointNameEnum | string): number {
    return Reflect.get(GridRowColSetting.TAB_MARGIN, bp);
  }

  /**
   * 根据栅格化动态获取列表数量
   * @returns
   */
  public static getColumnCountModel(currentColumnCount: number): string {
    let uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isSmallScreen(uiContext) && !DeviceUtils.isSmallSquare(uiContext)) {
      // 非阔折叠的直板设备
      return GridRowColSetting.getColumnModel(currentColumnCount, false)
    }
    if (DeviceUtils.isSmallScreen(uiContext) && DeviceUtils.isSmallSquare(uiContext)) {
      // 阔折叠的直板设备
      return GridRowColSetting.getColumnModel(currentColumnCount, false)
    }
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 折叠屏展开态
      return GridRowColSetting.getColumnModel(currentColumnCount, true)
    }
    return GridRowColSetting.getColumnModel(currentColumnCount, false)
  }

  public static getColumnModel(currentColumnCount: number, twice: boolean): string {
    if (currentColumnCount === 2) {
      return twice ? '1fr 1fr 1fr 1fr' : '1fr 1fr'
    } else if (currentColumnCount === 3) {
      return twice ? '1fr 1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr'
    } else if (currentColumnCount === 4) {
      return twice ? '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr' : '1fr 1fr 1fr 1fr'
    } else {
      return twice ? '1fr 1fr' : '1fr'
    }
  }
}