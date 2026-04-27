import { systemDateTime } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

const TAG = 'TimeUtil'

export class TimeUtil {
  static readonly MAX_TIME = Math.pow(10, 8) * 24 * 60 * 60 * 1000; // 8640000000000000 毫秒  Math.pow(10, 8)幂运算 10的8次方
  static readonly MIN_TIME = -TimeUtil.MAX_TIME; // -8640000000000000 毫秒

  // 日期+时间格式
  static readonly PATTERN_DATE_TIME_DEFAULT: string = 'yyyyMMddHHmmss'; // 年月日时分秒
  static readonly PATTERN_DATE_TIME_HYPHEN: string = 'yyyy-MM-dd HH:mm:ss'; // 日期中包含连字符/中划线(HYPHEN),时间是以冒号(Colon)分割
  static readonly PATTERN_DATE_TIME_HYPHEN_MS: string =
    'yyyy-MM-dd HH:mm:ss.SSS'; // 日期中包含连字符/中划线(HYPHEN),时间是以冒号(Colon)分割
  static readonly PATTERN_DATE_TIME_SLASH: string = 'yyyy/MM/dd HH:mm:ss'; // 日期中包含正斜杠(forward slash '/')
  static readonly PATTERN_DATE_TIME_BACK_SLASH: string = 'yyyy\\MM\\dd HH:mm:ss'; // 日期中包含反斜杠(back slash '\')
  static readonly PATTERN_DATE_TIME_DOT: string = 'yyyy.MM.dd HH:mm:ss'; // 日期中包含英文小圆点(DOT '.')
  static readonly PATTERN_DATE_TIME_CN: string = 'yyyy年MM月dd日 HH:mm:ss'; // 日期中包含包含中文年月日
  static readonly PATTERN_DATE_TIME_CN_MONTH: string = 'MM月dd日 HH:mm'; // 日期中包含包含中文年月日
  static readonly PATTERN_DATE_TIME_MS: string = 'yyyyMMddHHmmssSSS'; // 时间中包含毫秒
  static readonly PATTERN_DATE_TIME_WITHOUT_SECOND: string = 'yyyyMMddHHmm'; // 时间中不包含秒
  static readonly PATTERN_DATE_TIME_SIMPLIFY: string = 'MM/dd HH:mm'; // 精简的日期+时间(不包含年份和秒), 月/日 时:分

  // 仅日期格式(不包含时间)
  static readonly PATTERN_DATE_DEFAULT: string = 'yyyyMMdd'; // 年月日
  static readonly PATTERN_DATE_HYPHEN: string = 'yyyy-MM-dd'; // 日期中包含连字符/中划线(HYPHEN)
  static readonly PATTERN_DATE_SLASH: string = 'yyyy/MM/dd'; // 日期中包含正斜杠(forward slash '/')
  static readonly PATTERN_DATE_BACK_SLASH: string = 'yyyy\\MM\\dd'; // 日期中包含反斜杠(back slash '\')
  static readonly PATTERN_DATE_DOT: string = 'yyyy.MM.dd'; // 日期中包含英文小圆点(DOT '.')
  static readonly PATTERN_DATE_CN: string = 'yyyy年MM月dd日'; // 日期中包含包含中文年月日
  static readonly PATTERN_DATE_CN_WITHOUT_DAY: string = 'yyyy年MM月'; // 日期中不包含天，且year与month是中文
  static readonly PATTERN_DATE_CN_WITHOUT_YEAR: string = 'MM月dd日'; // 日期中不包含年份，且month与day是中文
  static readonly PATTERN_DATE_SLASH_WITHOUT_YEAR: string = 'MM/dd'; // 日期中不包含年份
  static readonly PATTERN_DATE_SLASH_WITHOUT_YEAR_OTHER: string = 'MM-dd'; // 日期中不包含年份

  // 仅时间格式(不包含日期)
  static readonly PATTERN_TIME_DEFAULT: string = 'HHmmss'; // 时分秒
  static readonly PATTERN_TIME_COLON: string = 'HH:mm:ss'; // 时间是以冒号(Colon)分割
  static readonly PATTERN_TIME_MS: string = 'HHmmssSSS'; // 时间中包含毫秒
  static readonly PATTERN_TIME_COLON_DOT_MS: string = 'HH:mm:ss.SSS'; // 时间是以冒号(Colon)与点号(DOT)分割，且包含毫秒
  static readonly PATTERN_TIME_WITHOUT_SECOND: string = 'HHmm'; // 时间中不包含秒
  static readonly PATTERN_TIME_COLON_WITHOUT_SECOND: string = 'HH:mm'; //  时间是以冒号(Colon)分割，且不包含秒
  static readonly PATTERN_TIME_COLON_WITHOUT_HOUR: string = 'mm:ss'; // 时间是以冒号(Colon)分割，且不包含小时(分钟长度至少2位，可能是3位)

  static readonly PATTERN_WEEK: string = 'E'; // 周几/星期几

  static readonly MONTHS_IN_YEAR: number = 12; // 1年12个月
  static readonly QUARTERS_IN_YEAR: number = 4; // 1年4个季度
  static readonly MONTHS_IN_QUARTER: number = 3; // 1季度3个月
  static readonly DAYS_MONTH: number[] = [31, 30, 29, 28]; // 每月多少天:大月(1/3/5/7/8/10/12月);小月(4/6/9/11月);2月(闰年29天/非闰月28天）
  static readonly DAYS_IN_WEEK: number = 7; // 1周7天
  static readonly HOURS_IN_DAY = 24; // 1天24小时
  // 分钟
  static readonly MINUTES_IN_HOUR = 60; // 1小时60分(时分秒之间的进制RADIX)
  static readonly MINUTES_IN_DAY = 1440 // 60 * 24 // 1天1440分钟
  // 秒
  static readonly SECONDS_IN_MINUTE = 60; // 1分60秒(时分秒之间的进制RADIX)
  static readonly SECONDS_IN_HOUR = 3600 // 60 * 60  // 1小时3600秒
  static readonly SECONDS_IN_DAY = 86400 // 60 * 60 * 24 // 1天86400秒
  // 毫秒
  static readonly MILLISECONDS_IN_SECOND: number = 1000; // 1秒是1000毫秒，秒与毫秒之间的转换进制RADIX
  static readonly MILLISECONDS_IN_MINUTE: number = 60000; // 1000 * 60 // 1分钟是60000毫秒
  static readonly MILLISECONDS_IN_HOUR: number = 3600000; // 1000 * 60 * 60 // 1小时是3600000毫秒
  static readonly MILLISECONDS_IN_DAY: number = 86400000; // 1000 * 60 * 60 * 24 // 1天是86400000毫秒

  static readonly YEAR: string = '年';
  static readonly MONTH: string = '月';
  static readonly DAY: string = '日';
  static readonly LAST_WEEK: string = '上周';
  static readonly BEFORE_YESTERDAY: string = '前天';
  static readonly YESTERDAY: string = '昨天';
  static readonly TODAY: string = '今天';
  static readonly TOMORROW: string = '明天';
  static readonly AFTER_TOMORROW: string = '后天';
  static readonly NEXT_WEEK: string = '下周';
  // 周x/星期X
  static readonly CHINESE_WEEK1: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  static readonly CHINESE_WEEK2: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  static readonly ENGLISH_WEEK1 = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static readonly ENGLISH_WEEK2 = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  static readonly ENGLISH_MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /**
   * 获取当前日期：秒数
   * 返回格式，默认如：1735069925
   */
  static getNowSecond(): number {
    let nowSecond: number = systemDateTime.getTime() / 1000
    nowSecond = Math.floor(nowSecond)
    return nowSecond
  }

  /**
   * 获取当前日期：年月日
   * 返回格式，默认如：yyyyMMdd,20230926
   */
  static getCurDate(format = TimeUtil.PATTERN_DATE_DEFAULT): string {
    const DATETIME = new Date()
    return TimeUtil.formatDate(DATETIME.getTime(), format)
  }

  /**
   * 获取当前时间：时分秒
   * 返回格式，默认如：HHmmss,230559
   */
  static getCurTime(format = TimeUtil.PATTERN_TIME_DEFAULT): string {
    const DATETIME = new Date()
    return TimeUtil.formatDate(DATETIME.getTime(), format)
  }


  /**
   * 获取今天的日期
   * @returns
   */
  static getToday(): Date {
    return new Date();
  }

  /**
   * 获取今天的时间戳
   * @returns
   */
  static getTodayTime(): number {
    return new Date().getTime();
  }

  /**
   * 当数字转字符串不足maxLength位时，用前导0补足maxLength位
   * @param value-数据值
   * @returns
   * 年份是4位
   * 月/日/时/分/秒，都是2位
   * 毫秒是3位
   */
  static fill(num: number, maxLength: number = 2): string {
    let value: string = '' + num
    return value.padStart(maxLength, '0')
  }

  /**
   * 获取两个时间点的时间差
   * @param milliseconds1
   * @param milliseconds2
   * @returns Duration
   */
  static getDuration(milliseconds1: number, milliseconds2: number): number {
    let date1 = new Date(milliseconds1)
    let date2 = new Date(milliseconds2)
    let timeDiff = Math.abs(date2.getTime() - date1.getTime());
    return timeDiff;
  }

  /**
   * 格式化Duration时间
   * @param duration 毫秒
   * @returns 返回格式化后的Duration时间
   */
  static getFormattedDuration(duration: number): string {
    // 也可以直接先除以1000转换为秒后再计算 // duration = duration/1000
    // Math.floor 用于向下取整
    let hour = Math.floor(duration / (TimeUtil.MILLISECONDS_IN_HOUR))
    // 用总毫秒数duration减去hour所对应的毫秒数差，再除以每分钟所占用的毫秒数
    let minute =
      Math.floor((duration - hour * (TimeUtil.MILLISECONDS_IN_HOUR)) / (TimeUtil.MILLISECONDS_IN_MINUTE));
    let second = Math.floor(duration / TimeUtil.MILLISECONDS_IN_SECOND) %
    TimeUtil.SECONDS_IN_MINUTE; // 先除以1000,转换为秒;再对整分钟取余
    if (hour > 0) {
      return `${TimeUtil.fill(hour)}:${TimeUtil.fill(minute)}:${TimeUtil.fill(second)}`
    }
    return `${TimeUtil.fill(minute)}:${TimeUtil.fill(second)}`
  }

  /**
   * 格式化显示倒计时
   * @param milliseconds 时间戳 毫秒
   * @returns 返回格式化后的Duration时间
   */
  static getDurationToNow(milliseconds: number): string {
    let nowDateTime = new Date();
    let duration = milliseconds - nowDateTime.getTime();
    if (duration < 0) {
      duration = 0;
    }
    return TimeUtil.getFormattedDuration(duration)
  }

  /**
   * 根据日期/时间字符串反序列化对应的时间戳
   * @param dateTimeString string 日期+时间字符串
   * 列举字符串格式,如:
   * 20231129,yyyyMMdd
   * 20231126230559 yyyyMMddHHmmss
   * 20231126230559729 yyyyMMddHHmmssSSS
   * 2023-11-26 23:05:59.729, yyyy-MM-dd HH:mm:ss.SSS(先移除所有中划线和冒号及空格等非数字字符)
   * 日期/时间字符串中包含连字符/中划线(Hyphen/Strike)/移除冒号(Colon)/移除空白字符(包括空格、制表符、换行符等)/移除正斜杠(forward slash '/')/移除反斜杠(back slash '\')
   * @param format:string 日期+时间的格式，默认格式：yyyy-MM-dd
   * @param referenceDate:Date 参考日期+时间
   * @returns 转换后的时间戳:milliseconds 毫秒
   * let dateTimeStr:string   = '(预告) 2024年12月24日 02:50 开播'
   * let formatPattern:string = '(预告) yyyy年MM月dd日 HH:mm 开播'
   * let parsedDate = TimeUtil.parseDate(dateTimeStr, formatPattern)
   */
  static parseDate(dateTimeString: string, format: string = TimeUtil.PATTERN_DATE_HYPHEN,
    referenceDate?: Date): number {
    if (!dateTimeString) {
      return 0
    }
    if (!referenceDate) {
      referenceDate = new Date(); // 参考当前时间
    }

    const optPatternList: string[] = ['y+', 'M+', 'd+', 'H+', 'm+', 's+', 'S+'];
    let dateParts: DateParts = {
      year: 0,
      month: 0,
      day: 0,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0
    }
    for (let i = 0; i < optPatternList.length; i++) {
      const optPattern = optPatternList[i];
      const regExp = new RegExp(optPattern, 'g');
      let matches = regExp.exec(format);
      if (!matches) {
        continue
      }

      TimeUtil.parseOptPattern(dateTimeString, optPattern, dateParts, matches, referenceDate);
    }
    let targetDate: Date =
      new Date(dateParts.year, dateParts.month, dateParts.day, dateParts.hour, dateParts.minute, dateParts.second,
        dateParts.millisecond)
    return targetDate.getTime()
  }

  static parseOptPattern(dateTimeString: string, optPattern: string, dateParts: DateParts, matches: RegExpExecArray,
    referenceDate: Date) {
    const pick = TimeUtil.parseNumber(dateTimeString.substring(matches.index, matches.index + matches[0].length));

    const config = TimeUtil.FIELD_PARSE_CONFIGS.find(item => item.pattern === optPattern);
    if (!config) {
      return;
    }

    const validValue = pick >= config.min && pick <= config.max ? pick : config.getDefault(referenceDate);
    config.setValue(dateParts, validValue);
  }

  private static readonly FIELD_PARSE_CONFIGS: FieldParseConfig[] = [
    {
      pattern: 'y+',
      min: -271821,
      max: 275760,
      getDefault: (refDate) => refDate.getFullYear(),
      setValue: (parts, val) => parts.year = val
    },
    {
      pattern: 'M+',
      min: 1,
      max: 12,
      getDefault: (refDate) => refDate.getMonth() + 1, // 原逻辑：参考日期月份+1（因用户输入是1-12）
      setValue: (parts, val) => parts.month = val - 1   // 原逻辑：月份减1（Date对象是0-11）
    },
    {
      pattern: 'd+',
      min: 1,
      max: 31,
      getDefault: (refDate) => refDate.getDate(),
      setValue: (parts, val) => parts.day = val
    },
    {
      pattern: 'H+',
      min: 0,
      max: 23,
      getDefault: (refDate) => refDate.getHours(),
      setValue: (parts, val) => parts.hour = val
    },
    {
      pattern: 'm+',
      min: 0,
      max: 59,
      getDefault: (refDate) => refDate.getMinutes(),
      setValue: (parts, val) => parts.minute = val
    },
    {
      pattern: 's+',
      min: 0,
      max: 59,
      getDefault: (refDate) => refDate.getSeconds(),
      setValue: (parts, val) => parts.second = val
    },
    {
      pattern: 'S+',
      min: 0,
      max: 999,
      getDefault: (refDate) => refDate.getMilliseconds(),
      setValue: (parts, val) => parts.millisecond = val
    }
  ];

  /**
   * 根据时间字符串反序列化对应的时长
   * @param dateTimeString string 时间字符串
   * 列举字符串格式,如:
   * "45:33",mm:ss
   * "2:45:33" HH:mm:ss
   * "02:45:33" HH:mm:ss
   * "02:45:33.567" HH:mm:ss.SSS
   * @param format:string 时长的格式，默认格式：HH:mm:ss.SSS
   * @returns 转换后的时长:milliseconds 毫秒
   * let dateTimeStr:string   = "02:50"
   * let formatPattern:string = "HH:mm"
   * let parsedDate = TimeUtil.parseDuration(dateTimeStr, formatPattern)
   */
  static parseDuration(dateTimeString: string, format: string = TimeUtil.PATTERN_TIME_COLON_DOT_MS): number {
    if (!dateTimeString) {
      return 0
    }
    const optPatternList: string[] = ['H+', 'm+', 's+', 'S+'];
    let targetHour: number = 0 // 时
    let targetMinute: number = 0 // 分
    let targetSecond: number = 0 // 秒
    let targetMillisecond: number = 0 // 毫秒
    for (let i = 0; i < optPatternList.length; i++) {
      const optPattern = optPatternList[i];
      const regExp = new RegExp(optPattern, 'g');
      let matches = regExp.exec(format);
      if (!matches) {
        continue
      }

      let pick: number =
        TimeUtil.parseNumber(dateTimeString.substring(matches.index, matches.index + matches?.[0].length))
      switch (optPattern) {
        case 'H+': // from 0 to 23
          if (pick >= 0 && pick <= 23) {
            targetHour = pick
          }
          break;
        case 'm+': // from 0 to 59
          if (pick >= 0 && pick <= 59) {
            targetMinute = pick
          }
          break;
        case 's+': // from 0 to 59
          if (pick >= 0 && pick <= 59) {
            targetSecond = pick
          }
          break;
        case 'S+': // from 0 to 999
          if (pick >= 0 && pick <= 999) {
            targetMillisecond = pick
          }
          break;
        default:
          break;
      }
    }
    return (targetHour * 60 * 60 + targetMinute * 60 + targetSecond) * 1000 + targetMillisecond
  }

  private static parseNumber(input: string, defValue?: number): number {
    // let input: string = '135'  // 135
    // let input: string = '135T' // NaN
    // let input: string = 'ytr'  // NaN
    // let input: string = ''     // 0
    // let input: string = null   // 0
    // let input: string = undefined  // NaN
    if (!input) {
      return defValue ?? 0
    }
    const parsedInt = Number(input)
    if (!isNaN(parsedInt)) {
      return parsedInt
    } else {
      return defValue ?? 0
    }
  }

  /**
   * 把整数时间戳格式化为指定格式的日期+时间字符串
   * @param timestamp:毫秒
   * @param format 指定要格式化的pattern，默认格式：yyyy-MM-dd
   * @returns 格式化后的字符串
   * 举例：
   * let date_fmt = DateTimeUtil.formatDate(dateTime, "预告 (E) MM月dd日 HH:mm 开播")
   */
  static formatDate(timestamp: number, format: string = TimeUtil.PATTERN_DATE_HYPHEN,
    isFill: boolean = true): string {
    try {
      const date = new Date(timestamp);
      let targetYear: string = date.getFullYear().toString();
      let targetMonth: string = isFill ? TimeUtil.fill(date.getMonth() + 1) : `${date.getMonth() + 1}`;
      let targetDay: string = isFill ? TimeUtil.fill(date.getDate()) : `${date.getDate()}`;
      let targetHours: string = TimeUtil.fill(date.getHours());
      let targetMinutes: string = TimeUtil.fill(date.getMinutes());
      let targetSeconds: string = TimeUtil.fill(date.getSeconds());
      let targetMilliseconds: string = TimeUtil.fill(date.getMilliseconds(), 3);
      let targetDayOfWeek: number = date.getDay();

      const dateOptionPatternList: string[] = ['y+', 'M+', 'd+', 'H+', 'm+', 's+', 'S+', 'E'];
      for (let i = 0; i < dateOptionPatternList.length; i++) {
        const dateOptionPattern = dateOptionPatternList[i];
        const dateOptionRegExp = new RegExp(dateOptionPattern);
        let match = dateOptionRegExp.exec(format); // 使用 RegExp 的exec 方法在目标字符串中查找匹配项
        if (!match) {
          continue
        }
        switch (dateOptionPattern) {
          case 'y+':
            format = format.replace(dateOptionRegExp, targetYear);
            break;
          case 'M+':
            format = format.replace(dateOptionRegExp, targetMonth);
            break;
          case 'd+':
            format = format.replace(dateOptionRegExp, targetDay);
            break;
          case 'H+':
            format = format.replace(dateOptionRegExp, targetHours);
            break;
          case 'm+':
            format = format.replace(dateOptionRegExp, targetMinutes);
            break;
          case 's+':
            format = format.replace(dateOptionRegExp, targetSeconds);
            break;
          case 'S+':
            format = format.replace(dateOptionRegExp, targetMilliseconds);
            break;
          case 'E': // from 0 to 6; the day of the week
            format = format.replace(dateOptionRegExp, TimeUtil.CHINESE_WEEK1[targetDayOfWeek]);
            break;
          default:
            break;
        }
      }
      return format;
    } catch (error) {
      return '';
    }
  }

  /**
   * 构造一周中的哪一天/构造星期X/周X
   * @param timestamp
   * @returns
   */
  static buildDayOfWeek(timestamp: number, weeks: string[] = TimeUtil.CHINESE_WEEK1): string {
    try {
      const date = new Date(timestamp);
      let day = date.getDay()
      let week = weeks[day];
      return week ?? ''
    } catch (error) {
      return ''
    }
  }

  static startOfDay(argument: number): Date {
    const _date = new Date(argument);
    _date.setHours(0, 0, 0, 0);
    return _date;
  }

  static isSameDay(dateLeft: number, dateRight: number): boolean {
    const dateLeftStartOfDay = TimeUtil.startOfDay(dateLeft);
    const dateRightStartOfDay = TimeUtil.startOfDay(dateRight);
    return dateLeftStartOfDay.getTime() === dateRightStartOfDay.getTime();
  }

  static addDays(argument: number, amount: number): Date {
    const _date = new Date(argument);
    if (amount === 0) {
      return _date;
    }
    _date.setDate(_date.getDate() + amount);
    return _date;
  }

  static subDays(date: number, amount: number): Date {
    return TimeUtil.addDays(date, -amount);
  }

  static isBeforeYesterday(date: number): boolean {
    return TimeUtil.isSameDay(date, TimeUtil.subDays(Date.now(), 2).getTime());
  }

  static isYesterday(date: number): boolean {
    return TimeUtil.isSameDay(date, TimeUtil.subDays(Date.now(), 1).getTime());
  }

  static isToday(date: number,): boolean {
    return TimeUtil.isSameDay(date, Date.now());
  }

  static isTomorrow(date: number): boolean {
    return TimeUtil.isSameDay(date, TimeUtil.addDays(Date.now(), 1).getTime());
  }

  static isAfterTomorrow(date: number): boolean {
    return TimeUtil.isSameDay(date, TimeUtil.addDays(Date.now(), 2).getTime());
  }

  // 检查指定的日期是过去的吗？
  static isPast(_date: Date): boolean {
    return _date.getTime() < Date.now();
  }

  // 检查指定的日期在未来/将来吗？
  static isFuture(_date: Date): boolean {
    return _date.getTime() > Date.now();
  }

  // 检查_date是在dateToCompare之后吗？，如
  // const result = isAfter(new Date(1989, 6, 10), new Date(1987, 1, 11))
  // => true
  static isAfter(_date: Date, dateToCompare: Date): boolean {
    return _date.getTime() > dateToCompare.getTime();
  }

  // 检查_date是在dateToCompare之前吗？，如
  // const result = isBefore(new Date(1989, 6, 10), new Date(1987, 1, 11))
  // => false
  static isBefore(_date: Date, dateToCompare: Date): boolean {
    return _date.getTime() < dateToCompare.getTime();
  }

  /**
   * 过去时间格式，与当前时间作比较
   * 3分钟之内 => 刚刚
   * 超过3分钟至1小时 => x分钟前
   * 超过1小时至昨天 => x小时前
   * 昨天 => 昨天 HH:mm
   * 3天内 => 2天前
   * 3天外 => MM-dd
   * 超过当年 YYYY-MM-dd
   */
  static formatAppointment(time: number): string {
    const currentTime = new Date().getTime()
    const diff = (currentTime - time) / 1000 / 60 // 分钟
    const diff1 = (currentTime - new Date().setHours(0, 0, 0, 0)) / 1000 / 60 //当前时间据凌晨分钟数
    if (diff <= 3) {
      return '刚刚'
    } else if (diff > 3 && diff <= 60) {
      return Math.floor(diff) + '分钟前'
    } else if (diff > 60 && diff <= diff1) {
      return Math.floor(diff / 60) + '小时前'
    } else if (diff > diff1 && diff <= diff1 + 24 * 60) {
      return '昨天' +
      TimeUtil.formatDate(time, TimeUtil.PATTERN_TIME_COLON_WITHOUT_SECOND)
    } else if (diff > diff1 + 24 * 60 && diff <= diff1 + 24 * 60 * 2) {
      return '两天前'
    } else {
      return TimeUtil.formatDate(time, TimeUtil.PATTERN_DATE_SLASH_WITHOUT_YEAR)
    }
  }

  /**
   * 预约时间格式，与当前时间作比较
   * 3分钟之内 => 刚刚
   * 超过3分钟至1小时 => x分钟前
   * 超过1小时至昨天 => x小时前
   * 昨天 => 昨天 HH:mm
   * 3天内 => 2天前
   * 3天外 => MM-dd
   * 超过当年 YYYY-MM-dd
   */
  static formatCommentData(time: number): string {
    const currentTime = new Date().getTime()
    const diff = (currentTime - time) / 1000 / 60 // 分钟
    const diff1 = (currentTime - new Date().setHours(0, 0, 0, 0)) / 1000 / 60 //当前时间据凌晨分钟数
    if (diff <= 3) {
      return '刚刚'
    } else if (diff > 3 && diff <= 60) {
      return Math.floor(diff) + '分钟前'
    } else if (diff > 60 && diff <= diff1) {
      return Math.floor(diff / 60) + '小时前'
    } else if (diff > diff1 && diff <= diff1 + 24 * 60) {
      return '昨天' +
      TimeUtil.formatDate(time, TimeUtil.PATTERN_TIME_COLON_WITHOUT_SECOND)
    } else if (diff > diff1 + 24 * 60 && diff <= diff1 + 24 * 60 * 2) {
      return '2天前'
    } else {
      return TimeUtil.formatDate(time, TimeUtil.PATTERN_DATE_SLASH_WITHOUT_YEAR_OTHER).replace('', '')
    }
  }

  // 定义一个函数用于将日期时间字符串转换为时间戳
  static convertDateTimeToTimestamp(dateTimeStr: string): number {
    let date: Date;
    try {
      date = new Date(dateTimeStr);
    } catch (e) {
      promptAction.showToast({ message: '日期时间格式不正确', duration: 2000 });
      return -1;
    }

    return date.getTime();
  }

  /**
   * 将日期字符串转换为 YYYY-MM-DD 格式
   * @param dateStr 原始日期字符串（支持 ISO 格式、普通日期时间格式等）
   * @returns 格式化后的日期字符串（如 "2025-10-28"），无效日期返回空字符串
   */
  static formatToDateString(dateStr: string): string {
    // 尝试将字符串转为 Date 对象
    const date = new Date(dateStr);

    // 校验日期有效性
    if (isNaN(date.getTime())) {
      return '';
    }

    // 获取年、月、日
    const year = date.getFullYear();
    const month = date.getMonth() + 1; // 月份从 0 开始，需 +1
    const day = date.getDate();

    // 补零处理（确保月份和日期为两位数）
    const paddedMonth = String(month).padStart(2, '0');
    const paddedDay = String(day).padStart(2, '0');

    // 拼接为 YYYY-MM-DD 格式
    return `${year}-${paddedMonth}-${paddedDay}`;
  }
}

// 定义日期字段解析配置接口（集中管理所有规则）
interface FieldParseConfig {
  pattern: string; // 匹配模式（如 'y+'、'M+'）
  min: number; // 数值最小值
  max: number; // 数值最大值
  getDefault: (date: Date) => number; // 从参考日期获取默认值的方法
  setValue: (parts: DateParts, value: number) => void; // 给DateParts赋值的方法
}

interface DateParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  millisecond: number;
}