export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  //全局对象存储Key
  public static readonly APP_STORAGE_DATA_KEY = 'AppStorageData';
  //待办类型
  public static readonly AGENCY_TASK_TABS =
    [$r('app.string.unfinished_task'), $r('app.string.finished_task')];
  //日期
  public static readonly WEEK_TITLE =
    [$r('app.string.sunday'), $r('app.string.monday'), $r('app.string.tuesday'), $r('app.string.wednesday'),
      $r('app.string.thursday'), $r('app.string.friday'), $r('app.string.saturday')];
  /**
   * The full percentage of component.
   */
  static readonly FULL_PERCENT: string = '100%';
  /**
   * Control button.
   */
  static readonly CONTROL_BUTTON: number = 40;
  /**
   * Calendar sideBar width.
   */
  static readonly SIDEBAR_WIDTH: number = 240;
  /**
   * Notes sideBar width.
   */
  static readonly NOTES_SIDEBAR_WIDTH: number = 304;
  /**
   * Calendar content width.
   */
  static readonly CALENDAR_CONTENT_WIDTH: number = 346;
  /**
   * Control button left.
   */
  static readonly CONTROL_BUTTON_LEFT: number = 256;
  /**
   * Control button top.
   */
  static readonly CONTROL_BUTTON_TOP: number = 44;
  /**
   * Control notes button top.
   */
  static readonly CONTROL_NOTES_BUTTON_TOP: number = 12;
  /**
   * Common margin.
   */
  static readonly COMMON_MARGIN: number = 16;
  /**
   * Common zero.
   */
  static readonly COMMON_ZERO: number = 0;
  /**
   * Common one.
   */
  static readonly COMMON_ONE: number = 1;
  /**
   * Common five.
   */
  static readonly COMMON_FIVE: number = 5;
  /**
   * Common six.
   */
  static readonly COMMON_SIX: number = 6;
  /**
   * Common seven.
   */
  static readonly COMMON_SEVEN: number = 7;
  /**
   * Breakpoint sm.
   */
  static readonly BREAK_POINT_SM: string = 'sm';
  /**
   * Breakpoint md.
   */
  static readonly BREAK_POINT_MD: string = 'md';
  /**
   * Breakpoint lg.
   */
  static readonly BREAK_POINT_LG: string = 'lg';
  static readonly DEVICE_TYPE_2IN1: string = '2in1';
  static readonly FONT_WEIGHT_500: number = 500;
  static readonly FONT_WEIGHT_400: number = 400;
  static readonly DATE_START: Date = new Date('2000-1-1');
  static readonly DATE_EDN: Date = new Date('2100-12-31');
  static readonly EN_LOCALE = 'en-US';
  static readonly FIELD_DAY = 'date';
  static readonly FIELD_MONTH = 'month';
  static readonly FIELD_YEAR = 'year';
  static readonly FIELD_HOUR = 'hour_of_day';
  static readonly FIELD_MINUTE = 'minute';
  static readonly FIELD_DAY_OF_WEEK = 'day_of_week';
  static readonly WEEK_VIEW: number = 0;
  static readonly MONTH_VIEW: number = 1;
  static readonly ONE_HOUR = 60 * 60 * 1000;
  static readonly HALF_HOUR = CommonConstants.ONE_HOUR / 2;
  static readonly ONE_DAY = 24 * 60 * 60 * 1000;
  static readonly SEVEN_DAY = 7 * CommonConstants.ONE_DAY;
}
