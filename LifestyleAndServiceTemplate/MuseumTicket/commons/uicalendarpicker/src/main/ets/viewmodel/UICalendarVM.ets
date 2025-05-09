import { Logger } from '@hw-agconnect/ui-base';
import { MonthDataSource, DayModel, MonthModel, UICalendarOptions, DatesItem, DateUtils } from '../common/Model';
import {
  DialogType,
  END_YEAR,
  FORMAT_MAP,
  MAX_GAP_DEFAULT,
  START_YEAR,
  SwiperDirection,
  TypePicker,
} from '../common/Constant';

@ObservedV2
export class UICalendarVM {
  // 外部传入
  @Trace type: TypePicker = TypePicker.SINGLE;
  @Trace dialogType: DialogType = DialogType.SHEET;
  @Trace swiperDirection: SwiperDirection = SwiperDirection.HORIZONTAL;
  @Trace customColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary_activated');
  @Trace customFontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  @Trace startDayOfWeek: number = 0;
  @Trace startYear: number = START_YEAR;
  @Trace endYear: number = END_YEAR;
  @Trace selected: Date | null = null;
  @Trace selectDates: Date[] = [];
  @Trace yOffset: number = 0;
  @Trace rangeLimit: Date[] = [];
  @Trace disabledDates: DatesItem[] = [];
  @Trace ableDates: DatesItem[] = [];
  @Trace disableDayLabel: ResourceStr = $r('app.string.disable_day_label');
  @Trace maxGap: number = MAX_GAP_DEFAULT;
  @Trace enableSelectTime: boolean = false;
  @Trace isMilitaryTime: boolean = false;
  @Trace sheetTitle: ResourceStr = '';
  // 内部变量
  @Trace inSelectedDate: Date | null = null;
  @Trace inSelectedDates: Date[] = [];
  @Trace selectedStartDate: Date | null = null;
  @Trace selectedEndDate: Date | null = null;
  // 用来承载当前视图的月份
  @Trace currShowDate: Date = new Date();
  @Trace yearMonthTuple: number[] = [];
  @Trace weekLabels: string[] = [];
  @Trace monthLabels: string[] = [];
  @Trace yearLabels: string[] = [];
  allowStart: DayModel | null = null;
  allowEnd: DayModel | null = null;
  @Trace curMonthIndex: number = 1;
  @Trace showTime: boolean = false;
  @Trace showNowLabel: boolean = true;
  selectedTime: TimePickerResult = {
    hour: 0,
    minute: 0,
    second: 0,
  };
  monthDataSource: MonthDataSource = new MonthDataSource();
  @Trace preMonth: MonthModel = new MonthModel(1, 1, []);
  @Trace currentMonth: MonthModel = new MonthModel(1, 1, []);
  @Trace nextMonth: MonthModel = new MonthModel(1, 1, []);
  listScroller: Scroller = new Scroller();
  private isInitScroll: boolean = true;
  private oldStart: number = 0;
  private oldEnd: number = 0;
  private minDisableDate: number = 0;
  private maxDisableDate: number = 0;
  private minAbleDate: number = 0;
  private maxAbleDate: number = 0;
  onSelected: (date: Date | Date[]) => void = () => {
  };
  onClickDate: (date: Date) => void = () => {
  };
  cancel: () => void = () => {
  };
  close: () => void = () => {
  };

  init(props?: UICalendarOptions) {
    this.assignProps(props);
    this.handleInputException();
    this.initConstants();
    this.initMonthData();
    if (this.disabledDates.length > 0) {
      this.minDisableDate = DateUtils.transDate2DayModel(this.disabledDates[0].date).getTimestamp();
      this.maxDisableDate =
        DateUtils.transDate2DayModel(this.disabledDates[this.disabledDates.length - 1].date).getTimestamp();
    }
    if (this.ableDates.length > 0) {
      this.minAbleDate = DateUtils.transDate2DayModel(this.ableDates[0].date).getTimestamp();
      this.maxAbleDate = DateUtils.transDate2DayModel(this.ableDates[this.ableDates.length - 1].date).getTimestamp();
    }
  }

  assignProps(props?: UICalendarOptions) {
    if (!props) {
      return;
    }
    this.type = props.type;
    this.dialogType = props.dialogType;
    this.swiperDirection = props.swiperDirection;
    this.customColor = props.customColor;
    this.customFontColor = props.customFontColor;
    this.startDayOfWeek = props.startDayOfWeek;
    this.startYear = props.startYear;
    this.endYear = props.endYear;
    this.selected = props.selected;
    this.selectDates = props.selectDates;
    this.yOffset = props.yOffset;
    this.rangeLimit = props.rangeLimit;
    this.disabledDates = props.disabledDates.sort((a, b) => a.date.getTime() - b.date.getTime());
    this.ableDates = props.ableDates.sort((a, b) => a.date.getTime() - b.date.getTime());
    this.disableDayLabel = props.disableDayLabel;
    this.maxGap = props.maxGap;
    this.enableSelectTime = props.enableSelectTime;
    this.isMilitaryTime = props.isMilitaryTime;
    this.sheetTitle = props.sheetTitle;
    this.onSelected = props.onSelected;
    this.onClickDate = props.onClickDate;
    this.cancel = props.cancel;
    this.close = props.close;
  }

  // 处理用户输入的异常情况
  handleInputException() {
    // 一周起始日不合法，需为0-6之间的整数
    const isStartDayOfWeekValid =
      this.startDayOfWeek >= 0 && this.startDayOfWeek <= 6 && Number.isInteger(this.startDayOfWeek);
    if (!isStartDayOfWeekValid) {
      this.startDayOfWeek = 0;
    }

    if (this.maxGap <= 0) {
      this.maxGap = MAX_GAP_DEFAULT;
    }

    this.handleStartEndYear();
    this.handleRangeLimit();
    if (this.type === TypePicker.SINGLE) {
      this.handleTypeSingle();
    } else if (this.type === TypePicker.MULTIPLE) {
      this.handleTypeMulti();
    } else {
      this.handleTypeRange();
    }

    // 单日期&水平滑动&开启时间选择
    if (this.type === TypePicker.SINGLE && this.swiperDirection === SwiperDirection.HORIZONTAL &&
    this.enableSelectTime) {
      this.showTime = true;
    }

    // 半模态标题
    if (!this.sheetTitle) {
      this.sheetTitle = this.showTime ? $r('app.string.title_datetime') : $r('app.string.title_date');
    }
  }

  // 常量的获取
  initConstants() {
    this.weekLabels = DateUtils.getWeekLabels(this.startDayOfWeek);
    this.monthLabels = DateUtils.getMonthLabels();
    this.yearLabels = DateUtils.getYearLabels(this.startYear, this.endYear);
  }

  initMonthData() {
    if (this.type === TypePicker.SINGLE) {
      this.currShowDate = DateUtils.correctSelectedDate(this.inSelectedDate, this.startYear, this.endYear);
    } else if (this.type === TypePicker.MULTIPLE) {
      this.currShowDate = DateUtils.correctSelectedDate(this.inSelectedDates[0], this.startYear, this.endYear);
    } else {
      this.currShowDate = DateUtils.correctSelectedDate(this.selectedStartDate, this.startYear, this.endYear);
    }
    Logger.info(`currShowDate is ${this.currShowDate.toLocaleDateString()}`);

    // 初始化时间
    if (this.showTime) {
      this.selectedTime.hour = this.currShowDate.getHours();
      this.selectedTime.minute = this.currShowDate.getMinutes();
      this.selectedTime.second = this.currShowDate.getSeconds();
    }

    this.yearMonthTuple = [this.currShowDate.getFullYear() - this.startYear, this.currShowDate.getMonth()];

    if (this.isSwiper()) {
      this.getSwiperMonths();
    } else {
      this.getListMonths();
    }
  }

  // 是否swiper容器
  isSwiper() {
    return this.dialogType === DialogType.DIALOG || this.swiperDirection === SwiperDirection.HORIZONTAL;
  }

  // 获取/更新月视图数据
  getSwiperMonths() {
    const lastMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() - 1);
    const nextMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() + 1);

    const _currentMonth =
      DateUtils.getMonthData(this.currShowDate.getFullYear(), this.currShowDate.getMonth() + 1, this.startDayOfWeek);
    this.handleSelected([_currentMonth]);
    DateUtils.assignMonth(this.currentMonth, _currentMonth);

    const _lastMonth =
      DateUtils.getMonthData(lastMonthDate.getFullYear(), lastMonthDate.getMonth() + 1, this.startDayOfWeek);
    this.handleSelected([_lastMonth]);
    DateUtils.assignMonth(this.preMonth, _lastMonth);

    const _nextMonth =
      DateUtils.getMonthData(nextMonthDate.getFullYear(), nextMonthDate.getMonth() + 1, this.startDayOfWeek);
    this.handleSelected([_nextMonth]);
    DateUtils.assignMonth(this.nextMonth, _nextMonth);
  }

  handleSelected(list: MonthModel[]) {
    if (this.type === TypePicker.MULTIPLE && this.inSelectedDates.length) {
      const inDays = this.inSelectedDates.map((v) => DateUtils.transDate2DayModel(v).getDateString());
      list.forEach((month: MonthModel) => {
        month.data.forEach((day: DayModel) => {
          if (inDays.includes(day.getDateString())) {
            day.setSelected(true);
          }
        });
      });
    }
  }

  getListMonths() {
    const list = DateUtils.getRoundMonths(this.currShowDate, this.startYear, this.endYear, this.startDayOfWeek);
    this.handleSelected(list);
    this.monthDataSource.batchPushData(list);
    this.curMonthIndex = list.findIndex((v) => v.year === this.currShowDate.getFullYear() &&
      v.month === this.currShowDate.getMonth() + 1);
    Logger.info(`initMonthData list length: ${list.length}, month range is ${list[0]?.getYearMonthString()}-${list[list.length -
      1]?.getYearMonthString()}, curMonthIndex: ${this.curMonthIndex}`);
  }

  handleStartEndYear() {
    // 取整
    this.startYear = Math.floor(this.startYear);
    this.endYear = Math.floor(this.endYear);
    // 1900年：支持的最小年份
    if (this.startYear < START_YEAR) {
      this.startYear = START_YEAR;
    }

    // 2100年：支持的最大年份
    if (this.endYear > END_YEAR) {
      this.endYear = END_YEAR;
    }

    // 起始年份大于结束年份
    if (this.startYear > this.endYear) {
      this.startYear = START_YEAR;
      this.endYear = END_YEAR;
    }
  }

  handleRangeLimit() {
    if (this.rangeLimit.length === 1) {
      const date = this.rangeLimit[0];
      this.allowStart = DateUtils.transDate2DayModel(date);
    } else if (this.rangeLimit.length >= 2) {
      const start = this.rangeLimit[0];
      const end = this.rangeLimit[1];
      if (start <= end) {
        this.allowStart = DateUtils.transDate2DayModel(start);
        this.allowEnd = DateUtils.transDate2DayModel(end);
      }
    }
  }

  handleTypeSingle() {
    const isValid =
      DateUtils.isValidDefaultDate(this.selected, this.startYear, this.endYear, this.allowStart, this.allowEnd,
        this.disabledDates.map((item: DatesItem) => {
          return item.date;
        }));
    this.inSelectedDate = isValid ? this.selected : null;
    if (this.inSelectedDate) {
      this.showNowLabel = false;
    }
  }

  handleTypeMulti() {
    // 过滤掉不合法日期
    this.inSelectedDates = this.selectDates
      .filter((item) => {
        return DateUtils.isValidDefaultDate(item, this.startYear, this.endYear, this.allowStart, this.allowEnd,
          this.disabledDates.map((item: DatesItem) => {
            return item.date;
          }));
      })
      .sort((a, b) => a.getTime() - b.getTime());

    // 去重
    DateUtils.removeDuplicate(this.inSelectedDates);
  }

  handleTypeRange() {
    this.selectDates.forEach((item: Date) => item.setHours(0, 0, 0, 0));

    // 存在不合法情况，清空数组
    const isSelectedInvalid = this.selectDates.length >= 2 &&
      (this.selectDates[0].getTime() >= this.selectDates[1].getTime()) ||
    this.selectDates.slice(0, 2).some((item) => {
      return !DateUtils.isValidDefaultDate(item, this.startYear, this.endYear, this.allowStart, this.allowEnd, []);
    });

    if (isSelectedInvalid) {
      Logger.info('Type Range input invalid, clear input array.');
      this.selectDates = [];
    }
    if (this.selectDates.length === 1) {
      this.selectedStartDate = this.selectDates[0];
    } else if (this.selectDates.length >= 2) {
      this.selectedStartDate = this.selectDates[0];
      this.selectedEndDate = this.selectDates[1];
    }
  }

  clickDate(item: DayModel) {
    try {
      const date = new Date(item.year, item.month - 1, item.day, this.selectedTime.hour, this.selectedTime.minute,
        this.selectedTime.second);
      if (this.onClickDate) {
        this.onClickDate(date);
      }

      // 单日期选择
      if (this.type === TypePicker.SINGLE) {
        this.inSelectedDate = date;
        if (this.dialogType === DialogType.DIALOG && !this.showTime) {
          this.confirmSelect();
        }
        return;
      }

      // 多日期选择
      if (this.type === TypePicker.MULTIPLE) {
        item.setSelected(!item.selected);
        const selectedList = this.inSelectedDates.map(v => DateUtils.transDate2DayModel(v).getDateString());
        const index = selectedList.findIndex(v => v === item.getDateString());
        if (index === -1) {
          this.inSelectedDates.push(date);
        } else {
          this.inSelectedDates.splice(index, 1);
        }
        return;
      }

      // 时间段选择
      if (!this.selectedStartDate) {
        this.selectedStartDate = date;
      } else if (this.selectedStartDate && this.selectedEndDate) {
        this.selectedStartDate = date;
        this.selectedEndDate = null;
      } else if (!this.selectedEndDate) {
        if (date.getTime() < this.selectedStartDate.getTime()) {
          this.selectedEndDate = this.selectedStartDate;
          this.selectedStartDate = date;
        } else if (date.getTime() > this.selectedStartDate.getTime()) {
          this.selectedEndDate = date;
        }
      }
    } catch (e) {
      Logger.error(`click date crash, exception: ${JSON.stringify(e)}`);
    }
  }

  confirmSelect() {
    Logger.info('calendar picker select finished.');
    if (this.type === TypePicker.SINGLE) {
      if (this.inSelectedDate) {
        this.confirm(this.inSelectedDate);
      }
    } else if (this.type === TypePicker.MULTIPLE) {
      this.confirm(this.inSelectedDates.sort((a: Date, b: Date) => a.getTime() - b.getTime()));
    } else {
      if (this.selectedStartDate && this.selectedEndDate) {
        this.confirm([this.selectedStartDate, this.selectedEndDate]);
      }
    }
    this.close();
  }

  confirm(date: Date | Date[]) {
    if (date instanceof Date) {
      this.selected = date;
    } else {
      this.selectDates = date;
    }
    this.onSelected(date);
  }

  cancelSelect() {
    Logger.info('calendar picker cancel.');
    this.cancel();
    this.close();
  }

  handleCurrentShow(date: Date) {
    this.currShowDate = date;
    this.currShowDate.setHours(this.selectedTime.hour, this.selectedTime.minute,
      this.selectedTime.second);
    this.yearMonthTuple = [this.currShowDate.getFullYear() - this.startYear, this.currShowDate.getMonth()];
  }

  // 横向Swiper滑动切换监听
  onAnimationStart(index: number, targetIndex: number) {
    Logger.info(`Swiper onAnimationStart, index: ${index}, targetIndex: ${targetIndex}`);
    if (this.curMonthIndex === targetIndex) {
      return;
    }
    this.curMonthIndex = targetIndex;
    // 判断是否左滑切换月份
    const IS_LEFT_SLIDE: boolean = (index === 1 && targetIndex === 0) || (index === 0 && targetIndex === 2) ||
      (index === 2 && targetIndex === 1);

    if (IS_LEFT_SLIDE) {
      // 获取上上个月视图数据
      const lastMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() - 1);
      this.handleCurrentShow(lastMonthDate);
      const beforeLastMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() - 1);
      const _beforeLastMonth =
        DateUtils.getMonthData(beforeLastMonthDate.getFullYear(), beforeLastMonthDate.getMonth() + 1,
          this.startDayOfWeek);
      this.handleSelected([_beforeLastMonth]);
      if (targetIndex === 0) {
        DateUtils.assignMonth(this.nextMonth, _beforeLastMonth);
      } else if (targetIndex === 1) {
        DateUtils.assignMonth(this.preMonth, _beforeLastMonth);
      } else if (targetIndex === 2) {
        DateUtils.assignMonth(this.currentMonth, _beforeLastMonth);
      }
    } else {
      // 获取下下个月视图数据
      const nextMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() + 1);
      this.handleCurrentShow(nextMonthDate);
      const afterNextMonthDate = new Date(this.currShowDate.getFullYear(), this.currShowDate.getMonth() + 1);
      const _afterNextMonth =
        DateUtils.getMonthData(afterNextMonthDate.getFullYear(), afterNextMonthDate.getMonth() + 1,
          this.startDayOfWeek);
      this.handleSelected([_afterNextMonth]);
      if (targetIndex === 0) {
        DateUtils.assignMonth(this.currentMonth, _afterNextMonth);
      } else if (targetIndex === 1) {
        DateUtils.assignMonth(this.nextMonth, _afterNextMonth);
      } else if (targetIndex === 2) {
        DateUtils.assignMonth(this.preMonth, _afterNextMonth);
      }
    }
  }

  getCurrentView() {
    if (this.curMonthIndex === 0) {
      return this.preMonth;
    }
    if (this.curMonthIndex === 1) {
      return this.currentMonth;
    }
    return this.nextMonth;
  }

  isReachStart() {
    const month = this.getCurrentView();
    return month.year === this.startYear && month.month === 1 || month.year < this.startYear;
  }

  isReachEnd() {
    const month = this.getCurrentView();
    return month.year === this.endYear && month.month === 12 || month.year > this.endYear;
  }

  // 逐帧判断是否能左右滑动
  onGestureRecognizerJudgeBegin(event: BaseGestureEvent, current: GestureRecognizer) {
    if (current.isBuiltIn() && current.getType() === GestureControl.GestureType.PAN_GESTURE) {
      let panEvent = event as PanGestureEvent;

      // 到达起始年月边界，不允许向左滑动
      if (this.isReachStart() && panEvent.velocityX > 0) {
        return GestureJudgeResult.REJECT;
      }

      // 到达结束年月边界，不允许向右滑动
      if (this.isReachEnd() && panEvent.velocityX < 0) {
        return GestureJudgeResult.REJECT;
      }
    }
    return GestureJudgeResult.CONTINUE;
  }


  // 纵向List滑动监听
  onScrollIndex(start: number, end: number, center: number) {
    Logger.info(`List onScrollIndex, start: ${start}, end: ${end}, center: ${center}`);

    // 列表初始化回调忽略
    if (this.isInitScroll) {
      this.oldStart = start;
      this.oldEnd = end;
      this.isInitScroll = false;
      Logger.info('system init trigger onScrollIndex, ignore');
      return;
    }

    const nearTop = start < this.oldStart && start <= 1;
    const nearBottom = end > this.oldEnd && end >= this.monthDataSource.totalCount() - 2;

    // 向上滑动
    if (nearTop) {
      const firstMonth = this.monthDataSource.getFirstData();
      const newList = DateUtils.getFirstHalfYearBySpecialMonth(firstMonth, this.startYear, this.startDayOfWeek);
      Logger.info(`Scroll up, old total length: ${this.monthDataSource.totalCount()}, load list length: ${newList.length}, now top month is: ${newList[0]?.getYearMonthString()}`);
      const showMonth = this.monthDataSource.getData(this.oldStart);
      this.handleSelected(newList);
      this.monthDataSource.batchPushDataHead(newList);
      const showMonthIndexNew = this.monthDataSource.getDataIndex(showMonth);
      // 避免顶部插入数据导致视图变化
      this.listScroller.scrollToIndex(showMonthIndexNew);
    }
    // 向下滑动
    if (nearBottom) {
      const finalMonth = this.monthDataSource.getFinalData();
      const newList = DateUtils.getSecondHalfYearBySpecialMonth(finalMonth, this.endYear, this.startDayOfWeek);
      Logger.info(`Scroll down, old total length: ${this.monthDataSource.totalCount()}, load list length: ${newList.length}, now bottom month is: ${newList[newList.length -
        1]?.getYearMonthString()}`);
      this.handleSelected(newList);
      this.monthDataSource.batchPushData(newList);
    }

    this.oldStart = start;
    this.oldEnd = end;

  }

  // 滚轮快捷选择年月
  changeYearMonth() {
    this.curMonthIndex = 1;
    const year = this.yearMonthTuple[0] + this.startYear;
    const month = this.yearMonthTuple[1];
    this.currShowDate = new Date(year, month, 1);
    this.currShowDate.setHours(this.selectedTime.hour, this.selectedTime.minute,
      this.selectedTime.second);
    this.getSwiperMonths();
  }

  // 是否展示禁用标签
  isShowDisabledLabel() {
    return [TypePicker.SINGLE, TypePicker.MULTIPLE].includes(this.type) && Boolean(this.disabledDates.length);
  }

  // 是否展示可选文字
  isShowLabel() {
    return [TypePicker.SINGLE, TypePicker.MULTIPLE].includes(this.type) && Boolean(this.ableDates.length);
  }

  // 是否属于禁用日期
  isDisabledDate(item: DayModel) {
    const timestamp = item.getTimestamp();
    if (timestamp < this.minDisableDate || timestamp > this.maxDisableDate) {
      return false;
    }
    return this.disabledDates.map((v: DatesItem) => DateUtils.transDate2DayModel(v.date).getDateString())
      .includes(item.getDateString());
  }

  // 是否属于可选日期
  isAbleDate(item: DayModel) {
    const timestamp = item.getTimestamp();
    if (timestamp < this.minAbleDate || timestamp > this.maxAbleDate) {
      return false;
    }
    return this.ableDates.map((v: DatesItem) => DateUtils.transDate2DayModel(v.date).getDateString())
      .includes(item.getDateString());
  }

  // 匹配对应禁用日期的label
  getDisableLabel(item: DayModel) {
    return this.disabledDates.find((v: DatesItem) => DateUtils.transDate2DayModel(v.date).getDateString() ===
    item.getDateString())?.label;
  }

  // 匹配对应可选日期的label
  getAbleLabel(item: DayModel) {
    return this.ableDates.find((v: DatesItem) => DateUtils.transDate2DayModel(v.date).getDateString() ===
    item.getDateString())?.label;
  }

  // 是否在限制的起止日期范围内
  isInCustomDateRange(item: DayModel) {
    let flag = true;
    if (this.allowStart) {
      flag = item.getTimestamp() >= this.allowStart.getTimestamp();
    }
    if (this.allowEnd) {
      flag = flag && (item.getTimestamp() <= this.allowEnd.getTimestamp());
    }
    return flag;
  }

  // 针对时间段类型，是否满足最大跨度的限制
  isInRangeGap(item: DayModel) {
    if (this.selectedStartDate && this.selectedEndDate) {
      return true;
    }
    if (this.selectedStartDate) {
      let daysAgo = this.selectedStartDate.getTime() - this.maxGap * 24 * 60 * 60 * 1000;
      let daysLater = this.selectedStartDate.getTime() + this.maxGap * 24 * 60 * 60 * 1000;
      return item.getTimestamp() >= daysAgo && item.getTimestamp() <= daysLater;
    }

    return true;
  }

  isEnable(item: DayModel) {
    // 非当月，禁止选择
    if (!item.isCurrMonth) {
      return false;
    }

    // 不在设定的起止日期范围
    if (!this.isInCustomDateRange(item)) {
      return false;
    }

    // 不可选择的日期，禁止选择
    if (this.isDisabledDate(item)) {
      return false;
    }
    // 传入少量可选日期
    if (this.ableDates.length !== 0 && !this.isAbleDate(item)) {
      return false;
    }

    // 针对时间段，不在gap内的日期禁止选择
    if (this.type === TypePicker.RANGE && !this.isInRangeGap(item)) {
      return false;
    }
    return true;
  }

  isToday(day: DayModel) {
    const date = new Date();
    const today = DateUtils.transDate2DayModel(date);
    return day.getDateString() === today.getDateString();
  }

  isSelected(day: DayModel) {
    if (this.type === TypePicker.SINGLE) {
      if (!this.inSelectedDate) {
        return false;
      }
      const selected = DateUtils.transDate2DayModel(this.inSelectedDate);
      return day.getDateString() === selected.getDateString();
    }

    if (this.type === TypePicker.MULTIPLE) {
      return day.selected;
    }

    if (!this.selectedStartDate) {
      return false;
    }
    const selectedStart = DateUtils.transDate2DayModel(this.selectedStartDate);
    if (!this.selectedEndDate) {
      return day.getDateString() === selectedStart.getDateString();
    }
    const selectedEnd = DateUtils.transDate2DayModel(this.selectedEndDate);
    return day.getDateString() === selectedStart.getDateString() || day.getDateString() === selectedEnd.getDateString();
  }

  // 是否是时间段类型
  isTypeRange() {
    return this.type === TypePicker.RANGE;
  }

  // 针对时间段选择场景 - 是否属于起止中间日期
  isInRange(day: DayModel) {
    if (this.type !== TypePicker.RANGE) {
      return false;
    }
    if (!this.selectedStartDate || !this.selectedEndDate) {
      return false;
    }
    const date = new Date(day.year, day.month - 1, day.day);

    // 针对竖向滑动，月份第一天和最后一天需要特殊处理
    if (this.swiperDirection === SwiperDirection.VERTICAL) {
      if (day.getTimestamp() === this.selectedStartDate.getTime() && DateUtils.isLastDayOfMonth(date)) {
        return false;
      }

      if (day.getTimestamp() === this.selectedEndDate.getTime() && DateUtils.isFirstDayOfMonth(date)) {
        return false;
      }
    }

    return date.getTime() >= this.selectedStartDate.getTime() &&
      date.getTime() <= this.selectedEndDate.getTime();
  }

  isStartDate(day: DayModel) {
    if (!this.selectedStartDate) {
      return false;
    }
    const date = new Date(day.year, day.month - 1, day.day);
    return date.getTime() === this.selectedStartDate.getTime();
  }

  isEndDate(day: DayModel) {
    if (!this.selectedEndDate) {
      return false;
    }
    const date = new Date(day.year, day.month - 1, day.day);
    return date.getTime() === this.selectedEndDate.getTime();
  }

  isSelectedValid() {
    if (this.type === TypePicker.SINGLE) {
      return Boolean(this.inSelectedDate);
    }
    if (this.type === TypePicker.MULTIPLE) {
      return this.inSelectedDates.length > 0;
    }
    return Boolean(this.selectedStartDate && this.selectedEndDate);
  }

  getFontColor(item: DayModel) {
    if (this.isSelected(item)) {
      return $r('sys.color.ohos_id_color_text_primary_contrary');
    }
    return this.isToday(item) ? this.customColor : this.customFontColor;
  }

  getTimeLabel(): ResourceStr {
    if (this.inSelectedDate && !this.showNowLabel) {
      return DateUtils.formatTimeSys(this.inSelectedDate,
        this.isMilitaryTime ? FORMAT_MAP.HOUR_24 : FORMAT_MAP.HOUR_12);
    }

    return $r('app.string.show_time_label');
  }

  isDayVisible(item: DayModel) {
    return this.swiperDirection === SwiperDirection.VERTICAL && !item.isCurrMonth ? Visibility.Hidden :
    Visibility.Visible;
  }
}