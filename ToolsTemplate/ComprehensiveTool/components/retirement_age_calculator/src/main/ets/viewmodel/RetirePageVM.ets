import {
  Constants,
  NEW_MAN_RETIRE_AGE,
  NEW_WOMAN_RETIRE_AGE,
  OLD_MAN_RETIRE_AGE,
  OLD_WOMAN_RETIRE_AGE,
} from '../common/Constant';
import { DateIndex, DateTimePickerOption } from '../model/Time';
import { DATE_TIME_RANGE } from '../utils/DateTimeRange';

@ObservedV2
export class RetirePageVM {
  private static _instance: RetirePageVM;
  @Trace isCalc: boolean = false
  @Trace text: string = '男职工';
  @Trace retirementAgeText: string = '';
  @Trace retirementAge: number = 0;
  @Trace retirementDate: Date | undefined = undefined;
  @Trace daysRemaining: number = 0;
  @Trace selectDate: Date = new Date();
  @Trace yearRange: string[] = [];
  @Trace monthRange: string[] = [];
  @Trace dayRange: string[] = [];
  @Trace currentYear: number = 0;
  @Trace currentMonth: number = 0;
  @Trace currentDay: number = 0;
  @Trace monthIndex: number = 0;
  @Trace dayIndex: number = 0;
  @Trace option: DateTimePickerOption | undefined;

  public static get instance() {
    if (!RetirePageVM._instance) {
      RetirePageVM._instance = new RetirePageVM();
    }
    return RetirePageVM._instance;
  }

  init() {
    this.isCalc = false
    this.text = '男职工';
    this.retirementAgeText = '';
    this.retirementAge = 0;
    this.retirementDate = undefined;
    this.daysRemaining = 0;
    this.selectDate = new Date();
    this.currentYear = this.selectDate.getFullYear();
    this.currentMonth = this.selectDate.getMonth() + 1;
    this.currentDay = this.selectDate.getDate();
    this.monthIndex = this.selectDate.getMonth();
    this.dayIndex = this.selectDate.getDate() - 1;
  }

  onChangedOption() {
    this.yearRange = DATE_TIME_RANGE.yearRange();
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);

    this.monthIndex = this.currentMonth - Constants.ONE;
    this.dayIndex = this.currentDay - Constants.ONE;
  }

  updateSelectedDate = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
    if (Array.isArray(value) || Array.isArray(index)) {
      return;
    }

    switch (dateIndex) {
      case DateIndex.YEAR:
        this.dealSelectedYear(value, index);
        break;
      case DateIndex.MONTH:
        this.dealSelectedMonth(value, index);
        break;
      case DateIndex.DAY:
        this.dealSelectedDay(value, index);
        break;
      default:
        this.dealSelectedDay(value, index);
        break;
    }
  };

  dealSelectedYear(value: string, index: number) {
    this.currentYear = Number(value.slice(Constants.ZERO, -Constants.ONE));
    this.monthRange = DATE_TIME_RANGE.monthRange(this.currentYear);
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedMonth(value: string, index: number) {
    this.currentMonth = Number(value.slice(Constants.ZERO, -Constants.ONE));
    this.monthIndex = index;
    this.dayRange = DATE_TIME_RANGE.dayRange(this.currentYear, this.currentMonth);
    this.updateDateTime();
  }

  dealSelectedDay(value: string, index: number) {
    this.currentDay = index + Constants.ONE;
    this.dayIndex = index;
    this.updateDateTime();
  }

  updateDateTime() {
    this.updateSolarDate();
  }

  updateSolarDate() {
    this.selectDate = new Date(
      this.currentYear,
      this.currentMonth - Constants.ONE,
      this.currentDay,
    );
  }

  calculateRetirement() {
    this.isCalc = true
    // 验证日期有效性
    if (isNaN(this.selectDate.getTime())) {
      throw new Error('无效的日期格式，请使用ISO8601格式（如\'1900-10-27T15:newWomanRetireAge:00.000Z\'）');
    }

    // 新规自2025年1月1日起
    const ruleData = new Date('2025-1-1')

    // 计算退休年龄
    if (this.text === '男职工') {
      this.retirementAge = OLD_MAN_RETIRE_AGE;
    } else {
      this.retirementAge = OLD_WOMAN_RETIRE_AGE;
    }

    // 计算延迟退休月数
    let addMonth = 0;
    if (this.text === '男职工') {
      addMonth =
        Math.ceil(((this.currentYear + OLD_MAN_RETIRE_AGE - ruleData.getFullYear()) * 12 + this.currentMonth) / 4)
      if (this.retirementAge + addMonth / 12 <= OLD_MAN_RETIRE_AGE) {
        this.retirementAge = OLD_MAN_RETIRE_AGE
        this.retirementAgeText = this.retirementAge + '岁'
        addMonth = 0
      } else if (this.retirementAge + addMonth / 12 >= NEW_MAN_RETIRE_AGE) {
        this.retirementAge = NEW_MAN_RETIRE_AGE
        this.retirementAgeText = this.retirementAge + '岁'
        addMonth = 0
      } else {
        this.retirementAgeText =
          this.retirementAge + Math.floor(addMonth / 12) + '岁' + (addMonth - Math.floor(addMonth / 12) * 12) + '月'
        if (addMonth - Math.floor(addMonth / 12) * 12 === 0) {
          this.retirementAgeText =
            this.retirementAge + Math.floor(addMonth / 12) + '岁'
        } else {
          this.retirementAgeText =
            this.retirementAge + Math.floor(addMonth / 12) + '岁' + (addMonth - Math.floor(addMonth / 12) * 12) + '月'
        }
      }
    } else {
      addMonth =
        Math.ceil(((this.currentYear + OLD_WOMAN_RETIRE_AGE - ruleData.getFullYear()) * 12 + this.currentMonth) / 4)
      if (this.retirementAge + addMonth / 12 <= OLD_WOMAN_RETIRE_AGE) {
        this.retirementAge = OLD_WOMAN_RETIRE_AGE
        this.retirementAgeText = this.retirementAge + '岁'
        addMonth = 0
      } else if (this.retirementAge + addMonth / 12 >= NEW_WOMAN_RETIRE_AGE) {
        this.retirementAge = NEW_WOMAN_RETIRE_AGE
        this.retirementAgeText = this.retirementAge + '岁'
        addMonth = 0
      } else {
        this.retirementAgeText =
          this.retirementAge + Math.floor(addMonth / 12) + '岁' + (addMonth - Math.floor(addMonth / 12) * 12) + '月'
        if (addMonth - Math.floor(addMonth / 12) * 12 === 0) {
          this.retirementAgeText =
            this.retirementAge + Math.floor(addMonth / 12) + '岁'
        } else {
          this.retirementAgeText =
            this.retirementAge + Math.floor(addMonth / 12) + '岁' + (addMonth - Math.floor(addMonth / 12) * 12) + '月'
        }
      }
    }

    // 计算退休日期（生日当天退休）
    const retirementDate = new Date(this.selectDate);
    retirementDate.setFullYear(this.selectDate.getFullYear() + this.retirementAge);
    retirementDate.setMonth(this.selectDate.getMonth() + addMonth);

    // 计算距离天数（含当天）
    const today = new Date();
    const daysRemaining = Math.ceil(
      (retirementDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
    );

    this.retirementDate = retirementDate;
    this.daysRemaining = daysRemaining > 0 ? daysRemaining : 0;
  }
}
