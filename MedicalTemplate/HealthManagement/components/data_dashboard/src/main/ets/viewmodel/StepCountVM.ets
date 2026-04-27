/**
 * 步数数据看板 ViewModel
 */
import { TimeRange, StepStatistics, StepRangeOption, SimpleMenuItem } from '../types/StepTypes';
import { STEP_RANGE_OPTIONS } from '../mock/StepMockData';

@ObservedV2
export class StepCountVM {
  private static _instance: StepCountVM;
  private rangeOptions: Record<TimeRange, StepRangeOption[]> = STEP_RANGE_OPTIONS;
  @Trace currentRange: TimeRange = TimeRange.WEEK;
  @Trace dateRangeText: string = '2024年02月27日 - 03月02日';
  @Trace periodText: string = '02月27日 - 03月02日';
  @Trace currentSteps: number = 4542;
  @Trace chartSteps: number[] = [1800, 6000, 2700, 900, 7500, 2500, 4600];
  @Trace chartLabels: string[] = [];
  @Trace statistics: StepStatistics = {
    total: 8000,
    average: 1398,
    calories: 230,
    distance: 0.98
  };
  @Trace showMenu: boolean = false;
  @Trace selectedRangeIndex: number = 0;
  @Trace showDateMenu: boolean = false;

  public static get instance(): StepCountVM {
    if (!StepCountVM._instance) {
      StepCountVM._instance = new StepCountVM();
    }
    return StepCountVM._instance;
  }

  /**
   * 初始化
   */
  public init(): void {
    this.applyRange(this.currentRange, 0);
  }

  /**
   * 切换时间范围
   */
  public switchTimeRange = (range: TimeRange): void => {
    this.currentRange = range;
    this.selectedRangeIndex = 0;
    this.applyRange(range, 0);
  }

  /**
   * 应用选择的范围
   */
  public applyRange(range: TimeRange, index: number): void {
    const options = this.rangeOptions[range];
    if (!options || options.length === 0) {
      return;
    }

    const safeIndex = Math.min(Math.max(index, 0), options.length - 1);
    const option = options[safeIndex];

    this.dateRangeText = option.label;
    this.periodText = option.period;
    this.currentSteps = option.currentSteps;
    this.chartSteps = option.steps.slice();
    this.chartLabels = option.labels.slice();
    this.statistics.total = option.statistics.total;
    this.statistics.average = option.statistics.average;
    this.statistics.calories = option.statistics.calories;
    this.statistics.distance = option.statistics.distance;
  }

  /**
   * 获取日期范围菜单项
   */
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

  /**
   * 切换菜单显示状态
   */
  public toggleMenu = (): void => {
    this.showMenu = !this.showMenu;
  }
  /**
   * 关闭所有菜单
   */
  public closeMenus = (): void => {
    this.showMenu = false;
    this.showDateMenu = false;
  }

  /**
   * 更新选中的数据（日期和步数）
   */
  public updateSelectedData = (date: string, steps: number): void => {
    this.periodText = date;
    this.currentSteps = steps;
  }
}

