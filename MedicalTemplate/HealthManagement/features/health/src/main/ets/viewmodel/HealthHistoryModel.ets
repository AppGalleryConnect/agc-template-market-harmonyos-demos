/**
 * 健康历史记录 Model
 */
import { HealthHistoryItem, MonthGroup } from '../types/HealthHistoryTypes';
import { HEALTH_HISTORY_GROUPS } from '../mock/HealthHistoryMockData';

@ObservedV2
export class HealthHistoryModel {
  private static _instance: HealthHistoryModel;

  historyGroups: MonthGroup[] = HEALTH_HISTORY_GROUPS;
  @Trace selectedMonth: string = '2025年4月';
  @Trace showMonthPicker: boolean = false;

  public static get instance() {
    if (!HealthHistoryModel._instance) {
      HealthHistoryModel._instance = new HealthHistoryModel();
    }
    return HealthHistoryModel._instance;
  }

  /**
   * 获取可选月份列表
   */
  public getMonthOptions(): string[] {
    return this.historyGroups.map(group => group.month);
  }

  /**
   * 获取当前选中月份的数据
   */
  public getCurrentMonthData(): HealthHistoryItem[] {
    const group = this.historyGroups.find(g => g.month === this.selectedMonth);
    return group ? group.items : [];
  }

  /**
   * 切换月份选择器
   */
  public toggleMonthPicker(): void {
    this.showMonthPicker = !this.showMonthPicker;
  }

  /**
   * 选择月份
   */
  public selectMonth(month: string): void {
    this.selectedMonth = month;
    this.showMonthPicker = false;
  }
}

