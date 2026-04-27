/**
 * 血糖数据看板 ViewModel
 */
import {
  TimeRange as BloodGlucoseTimeRange,
  BloodGlucoseStatistics,
  BloodGlucoseRangeOption,
  SimpleMenuItem
} from '../types/BloodGlucoseTypes';
import { BLOOD_GLUCOSE_RANGE_OPTIONS } from '../mock/BloodGlucoseMockData';

@ObservedV2
export class BloodGlucoseVM {
  private static _instance: BloodGlucoseVM;
  private rangeOptions: Record<BloodGlucoseTimeRange, BloodGlucoseRangeOption[]> = BLOOD_GLUCOSE_RANGE_OPTIONS;
  @Trace currentRange: BloodGlucoseTimeRange = BloodGlucoseTimeRange.WEEK;
  @Trace dateRangeText: string = '';
  @Trace periodText: string = '';
  @Trace currentValue: number = 0;
  @Trace chartValues: number[] = [];
  @Trace chartLabels: string[] = [];
  @Trace chartTooltipLabels: string[] = [];
  @Trace statistics: BloodGlucoseStatistics = {
    avgValue: 0,
    minValue: 0,
    maxValue: 0
  };
  @Trace showMenu: boolean = false;
  @Trace selectedRangeIndex: number = 0;
  @Trace showDateMenu: boolean = false;
  @Trace currentIndex: number = 0;

  public static get instance(): BloodGlucoseVM {
    if (!BloodGlucoseVM._instance) {
      BloodGlucoseVM._instance = new BloodGlucoseVM();
    }
    return BloodGlucoseVM._instance;
  }

  public init(): void {
    this.applyRange(this.currentRange, 0);
  }

  public switchTimeRange = (range: BloodGlucoseTimeRange): void => {
    this.currentRange = range;
    this.selectedRangeIndex = 0;
    this.applyRange(range, 0);
  }

  public applyRange(range: BloodGlucoseTimeRange, index: number): void {
    const options = this.rangeOptions[range];
    if (!options || options.length === 0) {
      return;
    }

    const safeIndex = Math.min(Math.max(index, 0), options.length - 1);
    const option = options[safeIndex];

    this.dateRangeText = option.label;
    this.periodText = option.period;
    this.currentValue = option.currentValue;
    this.chartValues = option.values.slice();
    this.chartLabels = option.labels.slice();
    this.chartTooltipLabels = option.tooltipLabels ? option.tooltipLabels.slice() : option.labels.slice();
    this.statistics.avgValue = option.statistics.avgValue;
    this.statistics.minValue = option.statistics.minValue;
    this.statistics.maxValue = option.statistics.maxValue;

    this.currentIndex = -1;
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

  public updateSelectedBloodGlucose = (date: string, value: number): void => {
    this.periodText = date;
    this.currentValue = value;
  }
}

