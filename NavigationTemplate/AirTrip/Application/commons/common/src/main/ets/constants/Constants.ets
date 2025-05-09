export default class Constants {
  // 人民币符号
  public static readonly RMB: string = '¥';
  // 姓名正则
  public static readonly NAME_REG: string = '^[\u4e00-\u9fa5A-Za-z]+$';
  // 订单支付的倒计时时长
  public static readonly PAY_COUNT_DOWN: number = 15*60*1000
  // 星期
  public static readonly WEEKS: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  // 农历月份的中文表示
  public static readonly CHINESE_MONTH: string[] =
    ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '腊'];
  // 农历日期的中文表示
  public static readonly CHINESE_DAY: string[] =
    ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];
  // 一天的总毫秒数。1000 * 60 * 60 * 24
  public static readonly TOTAL_MILLISECONDS_IN_DAY: number = 86400000;
  // 一周的天数
  public static readonly DAYS_IN_WEEK: number = 7;
  // 选中日期边框宽度
  public static readonly SELECT_DATE_BORDER_WIDTH: number = 1;
  // 默认值
  public static readonly DEFAULT: number = 0;
  // 今天日期
  public static readonly TODAY: number = new Date().getDate();
  // 本月
  public static readonly TODAY_MONTH: number = new Date().getMonth() + 1;
  // 本月
  public static readonly NOW_MONTH: number = new Date().getMonth();
  // 本年
  public static readonly TODAY_YEAR: number = new Date().getFullYear();

  /**
   * full width
   */
  public static readonly FULL_PERCENT_WIDTH: string = '100%';
  /**
   * full height
   */
  public static readonly FULL_PERCENT_HEIGHT: string = '100%';
}