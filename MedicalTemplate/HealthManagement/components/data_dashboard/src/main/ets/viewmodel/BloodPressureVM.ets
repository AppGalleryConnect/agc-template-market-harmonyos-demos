/**
 * 血压数据看板 ViewModel
 */
import {
  TimeRange as BloodPressureTimeRange,
  BloodPressureStatistics,
  BloodPressureRangeOption,
  SimpleMenuItem
} from '../types/BloodPressureTypes';
import { BLOOD_PRESSURE_RANGE_OPTIONS } from '../mock/BloodPressureMockData';

@ObservedV2
export class BloodPressureVM {
  private static _instance: BloodPressureVM;
  private rangeOptions: Record<BloodPressureTimeRange, BloodPressureRangeOption[]> = BLOOD_PRESSURE_RANGE_OPTIONS;
  @Trace currentRange: BloodPressureTimeRange = BloodPressureTimeRange.WEEK;
  @Trace dateRangeText: string = '';
  @Trace periodText: string = '';
  @Trace currentSystolic: number = 0;
  @Trace currentDiastolic: number = 0;
  @Trace chartSystolicValues: number[] = [];
  @Trace chartDiastolicValues: number[] = [];
  @Trace chartLabels: string[] = [];
  @Trace chartTooltipLabels: string[] = [];
  @Trace statistics: BloodPressureStatistics = {
    avgSystolic: 0,
    avgDiastolic: 0,
    avgPulse: 0
  };
  @Trace showMenu: boolean = false;
  @Trace selectedRangeIndex: number = 0;
  @Trace showDateMenu: boolean = false;
  @Trace currentIndex: number = 0;

  public static get instance(): BloodPressureVM {
    if (!BloodPressureVM._instance) {
      BloodPressureVM._instance = new BloodPressureVM();
    }
    return BloodPressureVM._instance;
  }

  public init(): void {
    this.applyRange(this.currentRange, 0);
  }

  public switchTimeRange = (range: BloodPressureTimeRange): void => {
    this.currentRange = range;
    this.selectedRangeIndex = 0;
    this.applyRange(range, 0);
  }

  public applyRange(range: BloodPressureTimeRange, index: number): void {
    const options = this.rangeOptions[range];
    if (!options || options.length === 0) {
      return;
    }

    const safeIndex = Math.min(Math.max(index, 0), options.length - 1);
    const option = options[safeIndex];

    this.dateRangeText = option.label;
    this.periodText = option.period;
    this.currentSystolic = option.currentSystolic;
    this.currentDiastolic = option.currentDiastolic;
    this.chartSystolicValues = option.systolicValues.slice();
    this.chartDiastolicValues = option.diastolicValues.slice();
    this.chartLabels = option.labels.slice();
    this.chartTooltipLabels = option.tooltipLabels ? option.tooltipLabels.slice() : [];
    this.statistics.avgSystolic = option.statistics.avgSystolic;
    this.statistics.avgDiastolic = option.statistics.avgDiastolic;
    this.statistics.avgPulse = option.statistics.avgPulse;

    if (range === BloodPressureTimeRange.WEEK || range === BloodPressureTimeRange.MONTH) {
      this.currentIndex = Math.floor(option.systolicValues.length / 2);
    } else {
      this.currentIndex = 0;
    }
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

  public updateSelectedBloodPressure = (date: string, systolic: number, diastolic: number): void => {
    this.periodText = date;
    this.currentSystolic = systolic;
    this.currentDiastolic = diastolic;
  }
}

