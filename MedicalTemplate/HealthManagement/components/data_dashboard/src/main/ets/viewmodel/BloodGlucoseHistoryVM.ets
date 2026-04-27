/**
 * 血糖历史记录 ViewModel
 */
import { MonthGroup, SimpleMenuItem } from '../types/BloodGlucoseTypes';
import { BLOOD_GLUCOSE_HISTORY_MONTHS } from '../mock/BloodGlucoseMockData';

@ObservedV2
export class BloodGlucoseHistoryVM {
  private static _instance: BloodGlucoseHistoryVM;
  @Trace months: MonthGroup[] = BLOOD_GLUCOSE_HISTORY_MONTHS;
  @Trace selectedMonthIndex: number = 0;
  @Trace showMonthMenu: boolean = false;

  public static get instance(): BloodGlucoseHistoryVM {
    if (!BloodGlucoseHistoryVM._instance) {
      BloodGlucoseHistoryVM._instance = new BloodGlucoseHistoryVM();
    }
    return BloodGlucoseHistoryVM._instance;
  }

  /**
   * 获取月份菜单项
   */
  public getMonthMenuItems(): SimpleMenuItem[] {
    const items: SimpleMenuItem[] = [];
    for (let i = 0; i < this.months.length; i++) {
      const index = i;
      items.push({
        action: () => {
          this.showMonthMenu = false;
          this.selectedMonthIndex = index;
        },
        value: this.months[i].monthTitle
      });
    }
    return items;
  }
}

