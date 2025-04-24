export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  /**
   * locationSwitch
   */
  static LOCATION_SWITCH_OFF: number = 3301100;

  static readonly APP_PATH_STACK : string = 'appPathStack';

  static readonly FULL_PERCENT: string = '100%';

  static readonly USER_INFO : string = 'userInfo';


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
   * locatingTimeoutMs
   */
  static LOCATING_TIMEOUT_MS: number = 100000;
  /**
   * locatingPriority
   */
  static PRIORITY_LOCATING_SPEED: number = 0x502;
}
