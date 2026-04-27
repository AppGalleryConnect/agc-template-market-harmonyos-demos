/**
 * 步数历史记录 ViewModel
 */
import { MonthGroup } from '../types/StepTypes';
import { STEP_HISTORY_MONTHS, STEP_HISTORY_STATISTICS } from '../mock/StepMockData';

interface MenuItem {
  value: string;
  action: () => void;
}

@ObservedV2
export class StepHistoryVM {
  private static _instance: StepHistoryVM;
  @Trace totalDuration: number = STEP_HISTORY_STATISTICS.totalDuration;
  @Trace totalCount: number = STEP_HISTORY_STATISTICS.totalCount;
  @Trace totalCalories: number = STEP_HISTORY_STATISTICS.totalCalories;
  @Trace months: MonthGroup[] = STEP_HISTORY_MONTHS;
  @Trace selectedMonthIndex: number = 0;
  @Trace showMonthMenu: boolean = false;

  public static get instance(): StepHistoryVM {
    if (!StepHistoryVM._instance) {
      StepHistoryVM._instance = new StepHistoryVM();
    }
    return StepHistoryVM._instance;
  }

  /**
   * 获取月份菜单项
   */
  public get monthMenuItems(): MenuItem[] {
    const items: MenuItem[] = [];
    for (let i = 0; i < this.months.length; i++) {
      const title = this.months[i].monthTitle;
      const index = i;
      items.push({
        value: title,
        action: () => {
          this.selectedMonthIndex = index;
          this.showMonthMenu = false;
        }
      });
    }
    return items;
  }

  /**
   * 切换月份菜单显示状态
   */
  public toggleMonthMenu = (): void => {
    this.showMonthMenu = !this.showMonthMenu;
  }
  /**
   * 关闭菜单
   */
  public closeMenu = (): void => {
    this.showMonthMenu = false;
  }
}

