export class Constants {
  public static readonly BACK_WIDTH: number = 24;
  public static readonly BACK_HEIGHT: number = 24;
  public static readonly BACK_BACKGROUND_WIDTH: number = 40;
  public static readonly BACK_BACKGROUND_HEIGHT: number = 40;
  public static readonly BTN_HEIGHT: number = 40;
  public static readonly MAX_WIDTH: number = 448;
  public static readonly SHEET_TITLE_H: number = 56;
  public static readonly ICON_WIDTH: number = 72;
  public static readonly ICON_HEIGHT: number = 72;
  public static readonly IMAGE_WIDTH: number = 48;
  public static readonly IMAGE_HEIGHT: number = 48;
  public static readonly COMB_WIDTH: number = 80;
  public static readonly CONTENT_MARGIN_TOP: number = 64;
  public static readonly LOGIN_MARGIN_TOP: number = 24;
  public static readonly FONT_LINES: number = 1;
  public static readonly BOX_WIDTH: number = 20;
  public static readonly BOX_HEIGHT: number = 20;
  public static readonly INPUT_HEIGHT: number = 56;
  public static readonly TEXT_HEIGHT: number = 16;
  public static readonly ROW_SPACE: number = 48;
  public static readonly DEFAULT_LOGIN_SHEET_HEIGHT: number = 622;
  public static readonly WINDOW_BOTTOM_PADDING: number = 28;
  public static readonly ZERO: number = 0;
  public static readonly MIN_HEIGHT_8: number = 8;
  public static readonly MIN_HEIGHT_12: number = 12;
  public static readonly MAX_HEIGHT_48: number = 48;
  public static readonly SPACE_S: number = 8;
  public static readonly SPACE_M: number = 12;
  public static readonly PADDING_S: number = 8;
  public static readonly PADDING_M: number = 12;
  public static readonly PADDING_L: number = 16;
  public static readonly PADDING_INPUT: number = 9;
  public static readonly FULL_PERCENT: Length = '100%';
}

export enum LoginType {
  WECHAT = 0
}

export enum LoginChannelType {
  HUAWEI = 0,
  WECHAT = 1,
  PHONENUMBER = 2
}

export enum LoginErrorCode {
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  ERROR_CODE_LOGIN_OUT = 1001502001,
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  ERROR_CODE_NOT_REQUIRED_SCOPE_OR_PERMISSION = 1001502014
}


