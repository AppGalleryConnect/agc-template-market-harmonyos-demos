/**
 * 睡眠数据看板 ViewModel
 */
import {
  TimeRange as SleepTimeRange,
  SleepStatistics,
  SleepRangeOption,
  SimpleMenuItem
} from '../types/SleepTypes';
import { SLEEP_RANGE_OPTIONS } from '../mock/SleepMockData';

@ObservedV2
export class SleepVM {
  private static _instance: SleepVM;
  private get rangeOptions(): Record<SleepTimeRange, SleepRangeOption[]> {
    return SLEEP_RANGE_OPTIONS;
  }
  @Trace currentRange: SleepTimeRange = SleepTimeRange.WEEK;
  @Trace dateRangeText: string = '';
  @Trace currentDateText: string = '';
  @Trace totalHour: number = 0;
  @Trace totalMinute: number = 0;
  @Trace chartSleepData: Array<[number, number, number, number]> = [];
  @Trace chartLabels: Array<string> = [];
  @Trace chartGroupSizes: Array<number> = [];
  @Trace statistics: SleepStatistics = {
    avgDeepSleep: 0,
    avgDeepSleepMinute: 0,
    avgLightSleep: 0,
    avgLightSleepMinute: 0,
    avgREM: 0,
    avgAwake: 0
  };
  @Trace showMenu: boolean = false;
  @Trace selectedRangeIndex: number = 0;
  @Trace showDateMenu: boolean = false;

  public static get instance(): SleepVM {
    if (!SleepVM._instance) {
      SleepVM._instance = new SleepVM();
    }
    return SleepVM._instance;
  }

  public static resetInstance(): void {
    SleepVM._instance = new SleepVM();
  }

  public init(): void {
    this.applyRange(this.currentRange, 0);
  }

  public switchTimeRange = (range: SleepTimeRange): void => {
    this.currentRange = range;
    this.selectedRangeIndex = 0;
    this.applyRange(range, 0);
  }

  public applyRange(range: SleepTimeRange, index: number): void {
    const options = this.rangeOptions[range];
    if (!options || options.length === 0) {
      return;
    }

    const safeIndex = Math.min(Math.max(index, 0), options.length - 1);
    const option = options[safeIndex];

    this.dateRangeText = option.label;
    this.currentDateText = option.currentDate;
    this.totalHour = option.totalHour;
    this.totalMinute = option.totalMinute;
    this.chartSleepData = option.sleepData.slice();
    this.chartLabels = option.labels.slice();
    this.chartGroupSizes = option.groupSizes ? option.groupSizes.slice() : [];
    this.statistics = {
      avgDeepSleep: option.statistics.avgDeepSleep,
      avgDeepSleepMinute: option.statistics.avgDeepSleepMinute,
      avgLightSleep: option.statistics.avgLightSleep,
      avgLightSleepMinute: option.statistics.avgLightSleepMinute,
      avgREM: option.statistics.avgREM,
      avgAwake: option.statistics.avgAwake
    };
  }

  public getDateRangeMenuItems(): SimpleMenuItem[] {
    const options = this.rangeOptions[this.currentRange] || [];
    const items: SimpleMenuItem[] = [];
    for (let i = 0; i < options.length; i++) {
      const option = options[i];
      const index = i;
      items.push({
        value: option.label,
        action: () => {
          this.selectedRangeIndex = index;
          this.applyRange(this.currentRange, index);
          this.showDateMenu = false;
        }
      });
    }
    return items;
  }

  public toggleMenu = (): void => {
    this.showMenu = !this.showMenu;
  }
  public closeMenus = (): void => {
    this.showMenu = false;
    this.showDateMenu = false;
  }

  /**
   * 更新选中的数据（日期和睡眠时长）
   */
  public updateSelectedData = (date: string, totalHours: number, totalMinutes: number): void => {
    this.currentDateText = date;
    this.totalHour = totalHours;
    this.totalMinute = totalMinutes;
  }
}

