export enum HomeServiceEnum {
  Home,
  Service,
  Code,
  News,
  Mine,
}

export enum ServiceListEnum {
  /*
   * 参保信息
   * */
  InsuranceInformation = 'insurance_information',
  /*
   * 就诊记录
   * */
  VisitRecords = 'visit_records',
  /*
   * 账户明细
   * */
  AccountDetails = 'account_details',
  /*
   * 医保地图
   * */
  HealthcareMap = 'healthcare_map',
  /*
   * 医保机构查询
   * */
  HealthInsurance = 'health_insurance',
  /*
   * 定点医院
   * */
  DesignatedHospital = 'designated_hospital',
  /*
   * 药品查询
   * */
  DrugInquiry = 'drug_inquiry',
  /*
    * 异地办事
    * */
  MakeAppointment = 'make_appointment',
  /*
   * 暂无此服务
   * */
  NotAvailable = 'not_available'

}


export enum PersonOperation {
  Scan,
  elders,
  code,
}

export class Constants {
  static readonly PAGE_PADDING: number = 10; // 页面内容内边距，用于悬浮窗位置计算
  static readonly ASPECT_RATIO: number = 1; // 图标宽高比
  static readonly PRODUCT_SERVICE_SPACE: number = 16; // 商品服务项间距
  static readonly FLOAT_WINDOW_WIDTH: number = 120; // 悬浮窗宽度
  static readonly FLOAT_WINDOW_HEIGHT: number = 160; // 悬浮窗高度
  static readonly INIT_POSITION_Y: number = 550; // 悬浮窗相对父容器左上角的Y坐标初始值
  static readonly FLEX_SHRINK: number = 1;
  static readonly FLEX_GROW: number = 1;
  static readonly LAYOUT_WEIGHT: number = 1;
  /**
   * NavDestination default.
   */
  public static readonly NAV_DESTINATION_DEFAULT: string = 'NavDestination_default';
  public static readonly NAV_MEDICAL_CODE: string = 'NavDestination_medical_code';
  /**
   * click set brightness
   */
  public static readonly SET_BRIGHTNESS_CLICK: number = -1;
  /**
   * slide set brightness
   */
  public static readonly SET_BRIGHTNESS_SLIDE: number = 1;
  /**
   * full width
   */
  public static readonly FULL_PERCENT_WIDTH: string = '100%';
  /**
   * full width
   */
  public static readonly NINETY_PERCENT_WIDTH: string = '90%';
  /**
   * Eighty width
   */
  public static readonly EIGHTY_PERCENT_WIDTH: string = '80%';
  /**
   * seventy width
   */
  public static readonly SEVENTY_PERCENT_WIDTH: string = '70%';
  /**
   * sixty-five width
   */
  public static readonly SIXTY_FIVE_PERCENT_WIDTH: string = '65%';
  /**
   * sixty width
   */
  public static readonly SIXTY_PERCENT_WIDTH: string = '60%';
  /**
   * half width
   */
  public static readonly HALF_PERCENT_WIDTH: string = '50%';
  /**
   * forty width
   */
  public static readonly FORTY_PERCENT_WIDTH: string = '40%';
  /**
   * half width
   */
  public static readonly THIRTY_PERCENT_WIDTH: string = '30%';
  /**
   * forty-five width
   */
  public static readonly FORTY_FIVE_PERCENT_WIDTH: string = '45%';
  /**
   * quarter width
   */
  public static readonly QUARTER_PERCENT_WIDTH: string = '25%';
  /**
   * full height
   */
  public static readonly FULL_PERCENT_HEIGHT: string = '100%';
  /**
   * Twenty height
   */
  public static readonly TWENTY_PERCENT_HEIGHT: string = '20%';
  /**
   * container space 20
   */
  public static readonly CONTAINER_SPACE_TWENTY: number = 20;
  /**
   * container space 12
   */
  public static readonly CONTAINER_SPACE_TWELVE: number = 20;
  /**
   * container space 10
   */
  public static readonly CONTAINER_SPACE_TEN: number = 10;
  /**
   * container space 5
   */
  public static readonly CONTAINER_SPACE_FIVE: number = 5;

  /**
   * container space 8
   */
  public static readonly CONTAINER_SPACE_EIGHT: number = 8;

  /**
   * half border radius
   */
  public static readonly HALF_PERCENT_RADIUS: string = '50%';
  /**
   * border radius 24
   */
  public static readonly RADIUS_TWENTY_FOUR: number = 24;
  /**
   * border radius 20
   */
  public static readonly RADIUS_TWENTY: number = 20;
  /**
   * border radius 18
   */
  public static readonly RADIUS_EIGHTEEN: number = 18;
  /**
   * border radius 16
   */
  public static readonly RADIUS_SIXTY: number = 16;
  /**
   * border radius 15
   */
  public static readonly RADIUS_FIFTEEN: number = 15;
  /**
   * border radius 12
   */
  public static readonly RADIUS_TWELVE: number = 12;
  /**
   * border radius 10
   */
  public static readonly RADIUS_TEN: number = 10;
  /**
   * border radius 8
   */
  public static readonly RADIUS_EIGHT: number = 8;
  /**
   * border radius 5
   */
  public static readonly RADIUS_FIVE: number = 5;
  /**
   * safe area 60
   */
  public static readonly SAFE_AREA_SIXTY: number = 60;
  /**
   * safe area 40
   */
  public static readonly SAFE_AREA_FORTY: number = 40;
  /**
   * safe area 20
   */
  public static readonly SAFE_AREA_TWENTY: number = 16;
  /**
   * safe area 10
   */
  public static readonly SAFE_AREA_TEN: number = 10;
  /**
   * font weight medium
   */
  public static readonly FONT_WEIGHT_MEDIUM: number = 500;
  /**
   * font size eight
   */
  public static readonly FONT_SIZE_EIGHT: number = 8;
  /**
   * font size ten
   */
  public static readonly FONT_SIZE_TEN: number = 10;
  /**
   * font size small
   */
  public static readonly FONT_SIZE_MINI: number = 12;
  /**
   * font size small
   */
  public static readonly FONT_SIZE_SMALL: number = 14;
  /**
   * font size normal
   */
  public static readonly FONT_SIZE_NORMAL: number = 16;
  /**
   * font size medium
   */
  public static readonly FONT_SIZE_MEDIUM: number = 18;
  /**
   * font size large
   */
  public static readonly FONT_SIZE_LARGE: number = 20;
}