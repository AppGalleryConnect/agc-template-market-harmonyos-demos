import { BreakpointType } from './GridRowColSetting';

/**
 * Common constants for common component.
 */
export class Constants {
  // Space
  static readonly SPACE_XXS: number = 2;
  static readonly SPACE_XS: number = 4;
  static readonly SPACE_S: number = 8;
  static readonly SPACE_M: number = 12;
  static readonly SPACE_L: number = 16;
  static readonly SPACE_XL: number = 20;
  static readonly SPACE_XXL: number = 24;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly QUARTER_PERCENT: string = '25%';
  // Padding
  static readonly PADDING_XXS: number = 2;
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_XL: number = 20;
  static readonly PADDING_XXL: number = 24;
  static readonly PADDING_PAGE: number = 16;
  static readonly RECOMMEND_INDEX: number = 0;
  static readonly DISCOVERY_INDEX: number = 1;
  static readonly LIKE_INDEX: number = 2;
  static readonly TREND_INDEX: number = 3;
  static readonly MINE_INDEX: number = 4;
  static readonly STATUS_PAUSE: number = 0;
  static readonly STATUS_PAUSE_EXPAND: number = 1;
  static readonly STATUS_PLAY_EXPAND: number = 2;
  static readonly STATUS_PLAY: number = 3;
  static readonly TAB_SPACE: number = 5;
  static readonly PLAY_ALL_TEXT: string = '播放全部';
  static readonly INIT_SUBWINDOW_POSITION_X: number = 0;
  static readonly INIT_SUBWINDOW_POSITION_Y: number = 200;
  static readonly INIT_SUBWINDOW_SIZE: number = 50;
  static readonly EXPANDED_SUBWINDOW_WIDTH: number = 181;
  static readonly FIVE_HUNDRED_FONT_WEIGHT: number = 500;
  static readonly WINDOW_BACKGROUND_COLOR: string = '#00000000';
  static readonly EXPAND_DELAY: number = 2000;
  static readonly CHANGE_FOCUS_DELAY: number = 500;
  static readonly HALF: number = 0.5;
  static readonly COMMON_LANES_1 = 1
  static readonly COMMON_LANES_2 = 2
  static readonly COMMON_LANES_3 = 3
  static readonly DEFAULT_SHEET_HEIGHT = 620
  static readonly PHONE_BOTTOM_TAB_BAR_HEIGHT = 48
  static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
  }
  static readonly DEFAULT_CENTER_COL_SPAN: GridColColumnOption = {
    xs: 1,
    sm: 1,
    md: 1,
    lg: 2,
  };
  static readonly FULL_SIZE = '100%'
  static readonly REQUEST_TIME_OUT = 3000
}


export class CardSizeConstants {
  public static smSize = 104
  public static mdSize = 164
  public static lgSize = 211
  public static xlSize = 211
}

export class CardTvWidthSizeConstants {
  public static smSize = 158
  public static mdSize = 222
  public static lgSize = 268
  public static xlSize = 268
}

export class CardTvHeightSizeConstants {
  public static smSize = 90
  public static mdSize = 124
  public static lgSize = 148
  public static xlSize = 148
}

/**
 * 广播卡片大小
 * */
export const broadcastSize: BreakpointType<number> = new BreakpointType<number>({
  sm: CardSizeConstants.smSize,
  md: CardSizeConstants.mdSize,
  lg: CardSizeConstants.lgSize,
  xl: CardSizeConstants.xlSize,
});

/**
 * 电视卡片宽度大小
 * */
export const televisionWidthSize: BreakpointType<number> = new BreakpointType<number>({
  sm: CardTvWidthSizeConstants.smSize,
  md: CardTvWidthSizeConstants.mdSize,
  lg: CardTvWidthSizeConstants.lgSize,
  xl: CardTvWidthSizeConstants.xlSize,
});

/**
 * 电视卡片高度大小
 * */
export const televisionHeightSize: BreakpointType<number> = new BreakpointType<number>({
  sm: CardTvHeightSizeConstants.smSize,
  md: CardTvHeightSizeConstants.mdSize,
  lg: CardTvHeightSizeConstants.lgSize,
  xl: CardTvHeightSizeConstants.xlSize,
});

/**
 * 广播卡片大小
 * */
export const broadcastLikeLanes: BreakpointType<number> = new BreakpointType<number>({
  sm: 3,
  md: 4,
  lg: 5,
  xl: 5,
});

/**
 * 电视卡片大小
 * */
export const televisionLanes: BreakpointType<number> = new BreakpointType<number>({
  sm: 2,
  md: 3,
  lg: 4,
  xl: 5,
});

/**
 * tablet下栅格
 * */
export const televisionTabletLanes: BreakpointType<number> = new BreakpointType<number>({
  lg: 2,
  xl: 2,
});

/**
 * 电视详情栅格
 * */
export const tvDetailsLanes: BreakpointType<number> = new BreakpointType<number>({
  sm: 1,
  md: 1,
  lg: 2,
  xl: 2,
});


export enum EmitterEvent {
  REFRESH_ORDER_LIST = 'refreshOrderList',
  REFRESH_MINE = 'refreshMine'
}