export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  /**
   * The login page tag.
   */
  static readonly TAG_LOGIN_PAGE: string = 'LoginPage';
  /**
   * The main page tag.
   */
  static readonly TAG_MAIN_PAGE: string = 'MainPage';
  /**
   * The mine page tag.
   */
  static readonly TAG_MINE_PAGE: string = 'MinePage';
  /**
   * Main page url.
   */
  static readonly MAIN_PAGE_URL: string = 'pages/MainPage';
  /**
   * Login page url.
   */
  static readonly LOGIN_PAGE_URL: string = 'pages/LoginPage';
  /**
   * locatingTimeoutMs
   */
  static LOCATING_TIMEOUT_MS: number = 100000;
  /**
   * locatingPriority
   */
  static PRIORITY_LOCATING_SPEED: number = 0x502;
  /**
   * locationScenario
   */
  static NAVIGATION: number = 0x401;
  /**
   * locationSwitch
   */
  static LOCATION_SWITCH_OFF: number = 3301100;
  /**
   * locationFail
   */
  static LOCATION_FAILED: number = 3301200;
  /**
   * reverseGeocodingFailed
   */
  static REVERSE_GEOCODING_FAILED: number = 3301300;
  /**
   * reverseGeocodingFailed
   */
  static WIFI_BLUETOOTH_OFF: number = 3301800;
  /**
   * Information Window Title
   */
  static MARKER_TITLE: string = getContext(this).resourceManager.getStringSync($r('app.string.geocoded_location'));

  public static readonly  PHONE_LENGTH_CN = 11;
  public static readonly STORE_KEY_ACTIVITY_BOOKING_RECORD = 'bookingRec';
}

export enum ActivityBookingStates{
  BOOKING,
  BOOKING_SUCCESS,
  CANCELED
}
