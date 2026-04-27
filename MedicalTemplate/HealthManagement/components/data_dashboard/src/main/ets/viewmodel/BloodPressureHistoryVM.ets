/**
 * 血压历史记录 ViewModel
 */
import { MonthGroup, SimpleMenuItem } from '../types/BloodPressureTypes';
import { BLOOD_PRESSURE_HISTORY_MONTHS } from '../mock/BloodPressureMockData';

@ObservedV2
export class BloodPressureHistoryVM {
  private static _instance: BloodPressureHistoryVM;
  @Trace months: MonthGroup[] = BLOOD_PRESSURE_HISTORY_MONTHS;
  @Trace selectedMonthIndex: number = 0;
  @Trace showMonthMenu: boolean = false;

  public static get instance(): BloodPressureHistoryVM {
    if (!BloodPressureHistoryVM._instance) {
      BloodPressureHistoryVM._instance = new BloodPressureHistoryVM();
    }
    return BloodPressureHistoryVM._instance;
  }

  /**
   * 获取月份菜单项
   */
  public getMonthMenuItems(): SimpleMenuItem[] {
    const items: SimpleMenuItem[] = [];
    for (let i = 0; i < this.months.length; i++) {
      const index = i;
      items.push({
        value: this.months[i].monthTitle,
        action: () => {
          this.showMonthMenu = false;
          this.selectedMonthIndex = index;
        }
      });
    }
    return items;
  }
}

