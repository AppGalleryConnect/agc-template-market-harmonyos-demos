export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

export class GridRowColSetting {
  public static readonly BREAK_POINT_VALUE: string[] =
    ['0', '600vp', '840vp', '1440vp'];

  public static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  }

  public static readonly GRID_ROW_OPTIONS_GUTTER_X: GridRowSizeOption = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
  }

  public static readonly WATER_FLOW_COLUMNS: GridRowColumnOption = {
    sm: 2,
    md: 4,
    lg: 4,
    xl: 4,
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

  public static getWaterFloColumns(bp: BreakpointNameEnum | string): string {
    return Array(Reflect.get(GridRowColSetting.WATER_FLOW_COLUMNS, bp)).fill('1fr').join(' ');
  }
}
