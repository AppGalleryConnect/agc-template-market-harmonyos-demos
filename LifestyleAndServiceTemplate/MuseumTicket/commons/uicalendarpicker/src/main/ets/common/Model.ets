import { DialogType, SwiperDirection, TypePicker } from './Constant';
import { i18n, intl } from '@kit.LocalizationKit';
import { FORMAT_MAP, configSM, configLG, LIST_CENTER_INDEX } from './Constant';

/**
 * 日期工具类
 */
export class DateUtils {
  /**
   * 用户偏好语言
   */
  static sysPreferredLanguage = i18n.System.getFirstPreferredLanguage();
  /**
   * 年份多语言格式
   */
  static dateFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { year: 'numeric' });
  /**
   * 月份多语言格式
   */
  static monthFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { month: 'short' });
  /**
   * 星期多语言格式
   */
  static weekFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { weekday: 'short' });

  /**
   * 获取本月视图中上个月数据
   * @param year
   * @param month
   * @param startDayOfWeek
   * @returns
   */
  static getLastMonth(year: number, month: number, startDayOfWeek: number): DayModel[] {
    const lastDate = new Date(year, month - 1, 0);
    const DAYS_OF_WEEK = 7;
    let daysNum = (lastDate.getDay() + 1) % DAYS_OF_WEEK;
    while (startDayOfWeek !== 0) {
      daysNum = daysNum === 0 ? DAYS_OF_WEEK - 1 : daysNum - 1;
      startDayOfWeek--;
    }
    const lastMonthData = [...new Array(daysNum)].map((item: number, index) => {
      return new DayModel(lastDate.getFullYear(), lastDate.getMonth() + 1, lastDate.getDate() - index, false);
    });

    return lastMonthData;
  };

  /**
   * 获取本月数据
   * @param year
   * @param month
   * @returns
   */
  static getCurrMonth(year: number, month: number): DayModel[] {
    const totalDays = new Date(year, month, 0).getDate();
    const monthData = [...new Array(totalDays)].map((item: number, index) => {
      return new DayModel(year, month, index + 1, true);
    });
    return monthData;
  };

  /**
   * 获取本月视图中包含的下月数据
   * @param year
   * @param month
   * @param startDayOfWeek
   * @returns
   */
  static getNextMonth(year: number, month: number, startDayOfWeek: number): DayModel[] {
    const firstDate = new Date(year, month, 1);
    const DAYS_OF_WEEK = 7;
    let daysNum = (DAYS_OF_WEEK - firstDate.getDay()) % DAYS_OF_WEEK;
    while (startDayOfWeek !== 0) {
      daysNum = (daysNum + 1) % DAYS_OF_WEEK;
      startDayOfWeek--;
    }
    const nextMonth = [...new Array(daysNum)].map((item: number, index) => {
      return new DayModel(firstDate.getFullYear(), firstDate.getMonth() + 1, index + 1, false);
    });

    return nextMonth;
  };

  /**
   * 获取月视图数据
   * @param year xxxx四位数字
   * @param month 1-12的数字
   * @param startDayOfWeek
   * @returns
   */
  static getMonthData(year: number, month: number, startDayOfWeek: number = 0): MonthModel {
    const monthData = DateUtils.getLastMonth(year, month, startDayOfWeek).reverse()
      .concat(DateUtils.getCurrMonth(year, month))
      .concat(DateUtils.getNextMonth(year, month, startDayOfWeek));
    return new MonthModel(year, month, monthData);
  };

  /**
   * 获取指定月份前后xx个月的数据
   * @param date
   * @param startYear
   * @param endYear
   * @param startDayOfWeek
   * @returns
   */
  static getRoundMonths(date: Date, startYear: number, endYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    const month = DateUtils.transDate2DayModel(date);

    for (let index = -LIST_CENTER_INDEX; index <= LIST_CENTER_INDEX; index++) {
      const date = new Date(month.year, month.month - 1 + index);
      if (date.getFullYear() < startYear) {
        continue;
      }
      if (date.getFullYear() > endYear) {
        break;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 获取指定月份前半年数据
   * @param month
   * @param startYear
   * @param startDayOfWeek
   * @returns
   */
  static getFirstHalfYearBySpecialMonth(month: MonthModel, startYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    // 已经到达年月边界
    if (month.year === startYear && month.month === 1) {
      return list;
    }

    for (let index = 6; index >= 1; index--) {
      const date = new Date(month.year, month.month - 1 - index);
      if (date.getFullYear() < startYear) {
        continue;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 获取指定月份后半年数据
   * @param month
   * @param endYear
   * @param startDayOfWeek
   * @returns
   */
  static getSecondHalfYearBySpecialMonth(month: MonthModel, endYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    // 已经到达年月边界
    if (month.year === endYear && month.month === 12) {
      return list;
    }

    for (let index = 1; index <= 6; index++) {
      const date = new Date(month.year, month.month - 1 + index);
      if (date.getFullYear() > endYear) {
        break;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 判断是否本月第一天
   * @param day
   * @returns
   */
  static isFirstDayOfMonth(day: Date) {
    const lastDayMonth = new Date(day);
    lastDayMonth.setDate(day.getDate() - 1);
    return day.getMonth() !== lastDayMonth.getMonth();
  };

  /**
   * 判断是否本月最后一天
   * @param day
   * @returns
   */
  static isLastDayOfMonth(day: Date) {
    const nextDayMonth = new Date(day);
    nextDayMonth.setDate(day.getDate() + 1);
    return day.getMonth() !== nextDayMonth.getMonth();
  };

  /**
   * 使用系统国际化api格式时间
   * @param date
   * @param format
   * @returns
   */
  static formatTimeSys(date: Date, format: FORMAT_MAP) {
    let dateFormat =
      new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { timeStyle: 'medium', hourCycle: format });
    return dateFormat.format(date);
  };

  /**
   * 格式化日期
   * @param date
   * @returns xxxx/xx/xx
   */
  static formatDate(date: Date): string {
    return `${date.getFullYear()}/${DateUtils.padZero(date.getMonth() + 1)}/${DateUtils.padZero(date.getDate())}`;
  }

  /**
   * 格式化时间
   * @param date
   * @returns xx:xx:xx
   */
  static formatTime(date: Date): string {
    return `${DateUtils.padZero(date.getHours())}:${DateUtils.padZero(date.getMinutes())}:${DateUtils.padZero(date.getSeconds())}`;
  };

  /**
   * 格式化日期时间
   * @param date
   * @returns xxxx/xx/xx xx:xx:xx
   */
  static formatDateTime(date: Date): string {
    return `${DateUtils.formatDate(date)} ${DateUtils.formatTime(date)}`;
  }

  /**
   * 不足两位数，补0
   * @param input
   * @returns
   */
  static padZero(input: number) {
    return input.toString().padStart(2, '0');
  };

  /**
   * 获取星期常量值
   * @returns
   */
  static getWeekLabelList() {
    // 定义一周7天
    const datesOfWeek = [
      new Date('2024-07-21'),
      new Date('2024-07-22'),
      new Date('2024-07-23'),
      new Date('2024-07-24'),
      new Date('2024-07-25'),
      new Date('2024-07-26'),
      new Date('2024-07-27'),
    ];

    return datesOfWeek.map((date) => DateUtils.weekFormat.format(date).toUpperCase());
  };

  /**
   * 获取指定一周起始日的星期常量值
   * @param startDayOfWeek
   * @returns
   */
  static getWeekLabels(startDayOfWeek: number = 0): string[] {
    const orders: number[] = [];
    let weekDays = 7;
    let initVal = startDayOfWeek;

    while (weekDays !== 0) {
      orders.push(initVal);
      initVal = (initVal + 1) % 7;
      weekDays--;
    }

    const weekLabels = DateUtils.getWeekLabelList();
    return orders.map((item: number) => {
      return weekLabels[item];
    });
  };

  /**
   * 系统格式化年，中文xxxx年，英文xxxx
   * @param year
   * @returns
   */
  static formatYear(year: string): string {
    return DateUtils.dateFormat.format(new Date(year));
  };

  /**
   * 获取所有年份的多语言常量
   * @param start
   * @param end
   * @returns
   */
  static getYearLabels(start: number, end: number): string[] {
    const list: string[] = [];
    for (let index = start; index <= end; index++) {
      list.push(DateUtils.formatYear(index.toString()));
    }
    return list;
  };

  /**
   * 通过系统api，获取12个月份的多语言常量
   * @returns
   */
  static getMonthLabels(): string[] {
    // 定义一年12月
    const monthsOfYear = [
      new Date('2024-01-01'),
      new Date('2024-02-01'),
      new Date('2024-03-01'),
      new Date('2024-04-01'),
      new Date('2024-05-01'),
      new Date('2024-06-01'),
      new Date('2024-07-01'),
      new Date('2024-08-01'),
      new Date('2024-09-01'),
      new Date('2024-10-01'),
      new Date('2024-11-01'),
      new Date('2024-12-01'),
    ];
    return monthsOfYear.map((date) => DateUtils.monthFormat.format(date));
  };

  /**
   * 设置当前视图所在月份
   * @param input 选择的日期
   * @param startYear 起始年份
   * @param endYear 结束年份
   * @returns
   */
  static correctSelectedDate(input: Date | null, startYear: number, endYear: number): Date {
    if (input) {
      return new Date(input);
    }

    // 默认先设置成系统日期
    let showDate: Date = new Date();

    // 选择日期早于起始年份
    if (showDate.getFullYear() < startYear) {
      return new Date(startYear, 0, 1, 0, 0, 0);
    }

    // 选择日期晚于结束年份
    if (showDate.getFullYear() > endYear) {
      return new Date(endYear, 11, 1, 0, 0, 0);
    }

    return showDate;
  }

  /**
   * 判断默认日期是否在范围内
   * @param input
   * @param startYear
   * @param endYear
   * @param allowStart
   * @param allowEnd
   * @param disabledDates
   * @returns
   */
  static isValidDefaultDate(input: Date | null, startYear: number, endYear: number, allowStart: DayModel | null,
    allowEnd: DayModel | null, disabledDates: Date[]): Boolean {
    if (!input) {
      return false;
    }
    const selected = new Date(input);
    selected.setHours(0, 0, 0, 0);

    // 早于起始年份
    if (selected.getFullYear() < startYear) {
      return false;
    }

    // 晚于结束年份
    if (selected.getFullYear() > endYear) {
      return false;
    }

    // 选择日期早于起始日期
    if (allowStart && selected.getTime() < allowStart.getTimestamp()) {
      return false;
    }

    // 选择日期晚于结束日期
    if (allowEnd && selected.getTime() > allowEnd.getTimestamp()) {
      return false;
    }

    // 在禁选日期范围内
    const disabled = disabledDates.map((date: Date) => {
      const nVal = new Date(date);
      nVal.setHours(0, 0, 0, 0);
      return nVal.getTime();
    });
    if (disabled.includes(selected.getTime())) {
      return false;
    }

    return true;
  }

  /**
   * 多日期去重
   * @param arr
   */
  static removeDuplicate(arr: Date[]) {
    let len = arr.length;
    for (let i = 0; i < len; i++) {
      for (let j = i + 1; j < len; j++) {
        if (arr[i].getTime() === arr[j].getTime()) {
          arr.splice(j, 1);
          len--;
          j--;
        }
      }
    }
  }

  /**
   * 获取相应断点下的配置
   * @param breakpoint
   * @returns
   */
  static getConfigByBreakpoint(breakpoint: string) {
    if (breakpoint === 'sm' || breakpoint === 'md') {
      return configSM;
    }
    return configLG;
  }

  /**
   * 将Date格式转换为DayModel格式
   * @param date
   * @returns
   */
  static transDate2DayModel(date: Date): DayModel {
    return new DayModel(date.getFullYear(), date.getMonth() + 1, date.getDate(), false);
  };

  /**
   * month数据key-value赋值
   * @param current
   * @param target
   */
  static assignMonth(current: MonthModel, target: MonthModel) {
    current.year = target.year;
    current.month = target.month;
    current.data = target.data;
  }
}




@ObservedV2
export class DatesItem {
  @Trace label: string = '';
  @Trace date: Date = new Date();
}

/**
 * 单日模型
 */
@ObservedV2
export class DayModel {
  @Trace year: number;
  @Trace month: number;
  @Trace day: number;
  @Trace lunarMonth: string = '';
  @Trace lunarDay: string = '';
  @Trace isFirstOfLunar: boolean = false;
  @Trace holiday: string = '';
  @Trace dayMark: string = '';
  @Trace isCurrMonth: boolean = true;
  @Trace isToday: boolean = false;
  @Trace selected: boolean = false;

  constructor(year: number, month: number, day: number, isCurrMonth: boolean, isToday: boolean = false) {
    this.year = year;
    this.month = month;
    this.day = day;
    this.isCurrMonth = isCurrMonth;
    this.isToday = isToday;
    this.selected = false;
  }

  /**
   * 设置是否选中
   * @param selected
   */
  setSelected(selected: boolean) {
    this.selected = selected;
  }

  /**
   * 返回年月，格式：1994-01
   * @returns
   */
  getYearMonth(): string {
    return `${this.year}-${DateUtils.padZero(this.month)}`;
  }

  /**
   * 返回具体日期，年月日，格式：1994-01-01
   * @returns
   */
  getDateString(): string {
    return `${this.year}-${DateUtils.padZero(this.month)}-${DateUtils.padZero(this.day)}`;
  }

  /**
   * 获取日期时间戳格式
   * @returns
   */
  getTimestamp(): number {
    const date = new Date(this.getDateString());
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }
}

/**
 * 单月模型
 */
@ObservedV2
export class MonthModel {
  // xxxx格式
  @Trace year: number;
  // 范围1-12
  @Trace month: number;
  @Trace data: DayModel[];

  constructor(year: number, month: number, data: DayModel[]) {
    this.year = year;
    this.month = month;
    this.data = data;
  }

  getYearMonthString() {
    return this.year + '_' + this.month;
  }
}



class BaseMonthDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: MonthModel[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): MonthModel {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }
}

export class MonthDataSource extends BaseMonthDataSource {
  private dataArray: MonthModel[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): MonthModel {
    return this.dataArray[index];
  }

  public getDataIndex(month: MonthModel): number {
    return this.dataArray.findIndex((v) => {
      return v.year === month.year && v.month === month.month;
    });
  }

  // 获取数组中第一个数据
  public getFirstData(): MonthModel {
    return this.dataArray[0];
  }

  // 获取数组中最后一个数据
  public getFinalData(): MonthModel {
    return this.dataArray[this.dataArray.length - 1];
  }

  // 在数组末尾，批量插入数据
  public batchPushData(data: MonthModel[]): void {
    const index = this.dataArray.length;
    this.dataArray.splice(index, 0, ...data);
    this.notifyDataAdd(index, data.length);
  }

  // 在数据头部，批量插入数据
  public batchPushDataHead(data: MonthModel[]): void {
    this.dataArray.splice(0, 0, ...data);
    this.notifyDataAdd(0, data.length);
  }

  // 在数组末尾，插入数据
  public pushData(data: MonthModel): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1, 1);
  }

  // 在数据头部，插入数据
  public pushDataHead(data: MonthModel): void {
    this.dataArray.splice(0, 0, data);
    this.notifyDataAdd(0, 1);
  }
}

/**
 * 开发者传参模型
 */
export interface UICalendarOptions {
  type: TypePicker;
  dialogType: DialogType;
  swiperDirection: SwiperDirection;
  customColor: ResourceColor;
  customFontColor: ResourceColor;
  startDayOfWeek: number;
  startYear: number;
  endYear: number;
  selected: Date;
  selectDates: Date[];
  yOffset: number;
  rangeLimit: Date[];
  disabledDates: DatesItem[];
  ableDates: DatesItem[];
  disableDayLabel: ResourceStr;
  maxGap: number;
  enableSelectTime: boolean;
  isMilitaryTime: boolean;
  sheetTitle: ResourceStr;
  onSelected: (date: Date | Date[]) => void;
  onClickDate: (date: Date) => void;
  cancel: () => void;
  close: () => void;
}
