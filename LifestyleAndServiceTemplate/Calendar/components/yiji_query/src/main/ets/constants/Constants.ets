export const weekdayMap = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

export const COL_SPAN: GridColColumnOption = {
  sm: 4,
  md: 4,
  lg: 6,
  xl: 6,
};

export const COL_OFFSET: GridColColumnOption = {
  sm: 0,
  md: 0,
  lg: 2,
  xl: 2,
};

export const YI_JI_OPTIONS: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 8,
    xl: 8,
  },
  gutter: { x: 5, y: 10 },
}

export const TABLET_GRID: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
}

export const YI_JI_COL: GridColColumnOption = {
  xs: 1,
  sm: 1,
  md: 1,
  lg: 1,
}

export const TABLE_COL: GridColColumnOption = {
  xs: 4,
  sm: 4,
  md: 8,
  lg: 8,
  xl: 8,
}

export const TABLE_COL_OFFSET: GridColColumnOption = {
  xs: 0,
  sm: 0,
  md: 0,
  lg: 2,
  xl: 2,
}

export const GRID_ROW_OPTIONS: GridRowOptions = {
  columns: {
    xs: 4,
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
  gutter: {
    x: {
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
    },
    y: {
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
    },
  },
  breakpoints: {
    value: ['0', '600vp', '840vp', '1440vp'],
    reference: BreakpointsReference.WindowSize,
  },
  direction: GridRowDirection.Row,
};