export interface BreakpointTypeOptions<T> {
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
}

export class BreakpointType<T> {
  private options: BreakpointTypeOptions<T>;

  constructor(options: BreakpointTypeOptions<T>) {
    this.options = options;
  }

  public getValue(breakpoint: string): T {
    switch (breakpoint) {
      case BreakpointNameEnum.MD:
        return this.options.md!;
      case BreakpointNameEnum.LG:
        return this.options.lg!;
      case BreakpointNameEnum.XL:
        return this.options.xl!;
      case BreakpointNameEnum.SM:
      default:
        return this.options.sm!;
    }
  }
}

export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

export enum BreakpointValueEnum {
  SM = '600vp',
  MD = '840vp',
  LG = '1440vp',
}

export class GridRowColSetting {
  public static readonly BREAK_POINT_VALUE: string[] = ['0', BreakpointValueEnum.SM, BreakpointValueEnum.MD,
    BreakpointValueEnum.LG];

  public static readonly DIALOG_MAX_WIDTH: number = 480;

  public static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  };

  public static readonly GRID_ROW_OPTIONS_GUTTER_X: GridRowSizeOption = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
  };

  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };

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

  public static readonly DEFAULT_CENTER_COL_SPAN: GridColColumnOption = {
    sm: 4,
    md: 8,
    lg: 8,
    xl: 8,
  };

  public static readonly DEFAULT_CENTER_COL_OFFSET: GridColColumnOption = {
    sm: 0,
    md: 0,
    lg: 2,
    xl: 2,
  };

  public static readonly SMALL_CENTER_COL_SPAN: GridColColumnOption = {
    sm: 4,
    md: 6,
    lg: 6,
    xl: 6,
  };

  public static readonly SMALL_CENTER_COL_OFFSET: GridColColumnOption = {
    sm: 0,
    md: 1,
    lg: 3,
    xl: 3,
  };

  public static getPageMargin(breakpoint: BreakpointNameEnum | string): number {
    switch (breakpoint) {
      case BreakpointNameEnum.MD:
        return 24;
      case BreakpointNameEnum.LG:
        return 32;
      case BreakpointNameEnum.XL:
        return 32;
      case BreakpointNameEnum.SM:
      default:
        return 16;
    }
  }
}
