export const GRID_ROW_OPTIONS: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
  gutter: {
    x: {
      sm: 16,
      md: 18,
      lg: 20,
      xl: 24,
    },
    y: {
      sm: 20,
      md: 24,
      lg: 28,
      xl: 30,
    },
  },
  breakpoints: {
    value: ['0', '600vp', '840vp', '1440vp'],
    reference: BreakpointsReference.WindowSize,
  },
  direction: GridRowDirection.Row,
};

export const GRID_ROW_OPTIONS_Y_8: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
  gutter: {
    x: {
      sm: 16,
      md: 18,
      lg: 20,
      xl: 24,
    },
    y: {
      sm: 8,
      md: 8,
      lg: 8,
      xl: 8,
    },
  },
  breakpoints: {
    value: ['0', '600vp', '840vp', '1440vp'],
    reference: BreakpointsReference.WindowSize,
  },
  direction: GridRowDirection.Row,
};

export const COL_SPAN: GridColColumnOption = {
  sm: 4,
  md: 4,
  lg: 6,
  xl: 6,
};
