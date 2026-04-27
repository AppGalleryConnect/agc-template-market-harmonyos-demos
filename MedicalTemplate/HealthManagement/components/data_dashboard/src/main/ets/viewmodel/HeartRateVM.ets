/**
 * 心率数据看板 ViewModel
 */
import {
  TimeRange as HeartRateTimeRange,
  HeartRateStatistics,
  HeartRateRangeOption,
  SimpleMenuItem
} from '../types/HeartRateTypes';
import { HEART_RATE_RANGE_OPTIONS } from '../mock/HeartRateMockData';

@ObservedV2
export class HeartRateVM {
  private static _instance: HeartRateVM;
  private rangeOptions: Record<HeartRateTimeRange, HeartRateRangeOption[]> = HEART_RATE_RANGE_OPTIONS;
  @Trace currentRange: HeartRateTimeRange = HeartRateTimeRange.WEEK;
  @Trace dateRangeText: string = '';
  @Trace periodText: string = '';
  @Trace currentRangeText: string = '';
  @Trace chartRanges: Array<[number, number]> = [];
  @Trace chartLabels: Array<string> = [];
  @Trace chartTooltipLabels: Array<string> = [];
  @Trace chartGroupSizes: Array<number> = [];
  @Trace statistics: HeartRateStatistics = {
    avgHigh: 0,
    avgLow: 0,
    restingHigh: 0,
    restingLow: 0
  };
  @Trace showMenu: boolean = false;
  @Trace selectedRangeIndex: number = 0;
  @Trace showDateMenu: boolean = false;

  public static get instance(): HeartRateVM {
    if (!HeartRateVM._instance) {
      HeartRateVM._instance = new HeartRateVM();
    }
    return HeartRateVM._instance;
  }

  public init(): void {
    this.applyRange(this.currentRange, 0);
  }

  public switchTimeRange = (range: HeartRateTimeRange): void => {
    this.currentRange = range;
    this.selectedRangeIndex = 0;
    this.applyRange(range, 0);
  }

  public applyRange(range: HeartRateTimeRange, index: number): void {
    const options = this.rangeOptions[range];
    if (!options || options.length === 0) {
      return;
    }

    const safeIndex = Math.min(Math.max(index, 0), options.length - 1);
    const option = options[safeIndex];

    this.dateRangeText = option.label;
    this.periodText = option.period;
    this.currentRangeText = option.currentRange;
    this.chartRanges = option.ranges.slice();
    this.chartLabels = option.labels.slice();
    this.chartTooltipLabels = option.tooltipLabels ? option.tooltipLabels.slice() : option.labels.slice();
    this.chartGroupSizes = option.groupSizes ? option.groupSizes.slice() : [];
    this.statistics.avgHigh = option.statistics.avgHigh;
    this.statistics.avgLow = option.statistics.avgLow;
    this.statistics.restingHigh = option.statistics.restingHigh;
    this.statistics.restingLow = option.statistics.restingLow;
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
}

