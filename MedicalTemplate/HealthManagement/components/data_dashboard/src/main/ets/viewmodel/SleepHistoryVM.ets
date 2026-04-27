/**
 * 睡眠历史记录 ViewModel
 */
import { MonthGroup as SleepMonthGroup, SleepHistoryItem, SleepRecord } from '../types/SleepTypes';
import { SLEEP_HISTORY_MONTHS } from '../mock/SleepMockData';
import { SleepDetailVM } from './SleepDetailVM';

interface MenuItem {
  value: string;
  action: () => void;
}

@ObservedV2
export class SleepHistoryVM {
  @Trace selectedMonthIndex: number = 0;
  @Trace showMonthMenu: boolean = false;
  private static _instance: SleepHistoryVM;
  @Trace months: SleepMonthGroup[] = SLEEP_HISTORY_MONTHS;

  public static get instance(): SleepHistoryVM {
    if (!SleepHistoryVM._instance) {
      SleepHistoryVM._instance = new SleepHistoryVM();
    }
    return SleepHistoryVM._instance;
  }

  public getMonthMenuItems(): MenuItem[] {
    const items: MenuItem[] = [];
    for (let i = 0; i < this.months.length; i++) {
      const title = this.months[i].monthTitle;
      const index = i;
      items.push({
        action: () => {
          this.selectedMonthIndex = index;
          this.showMonthMenu = false;
        },
        value: title
      });
    }
    return items;
  }


  public closeMenu = (): void => {
    this.showMonthMenu = false;
  }

  public toggleMonthMenu = (): void => {
    this.showMonthMenu = !this.showMonthMenu;
  }

  /**
   * 设置详情页数据
   */
  public setDetailData(item: SleepHistoryItem): void {
    // 从dateTime中提取日期，格式如"4月28日"
    const dateTitle = item.dateTime;

    // 根据日期生成开始和结束时间
    // 假设睡眠从晚上22:30开始
    const dateParts = dateTitle.match(/(\d+)月(\d+)日/);
    if (dateParts) {
      const month = dateParts[1];
      const day = dateParts[2];

      // 解析睡眠时长，格式如"8小时30分钟"
      const durationMatch = item.duration.match(/(\d+)小时(\d+)分钟/);
      let totalMinutes = 0;
      if (durationMatch) {
        const hours = parseInt(durationMatch[1]);
        const minutes = parseInt(durationMatch[2]);
        totalMinutes = hours * 60 + minutes;
      }

      // 计算结束时间（假设从22:30开始）
      const startHour = 22;
      const startMinute = 30;
      const endTotalMinutes = startHour * 60 + startMinute + totalMinutes;
      const endHour = Math.floor(endTotalMinutes / 60) % 24;
      const endMinute = endTotalMinutes % 60;
      const nextDay = endTotalMinutes >= 24 * 60 ? parseInt(day) + 1 : parseInt(day);

      const records: SleepRecord[] = [
        { label: '睡眠', value: item.duration },
        { label: '开始时间', value: `2025/${month}/${day} ${startHour}:${startMinute.toString().padStart(2, '0')}` },
        { label: '结束时间', value: `2025/${month}/${nextDay} ${endHour.toString().padStart(2, '0')}:${endMinute.toString().padStart(2, '0')}` }
      ];

      SleepDetailVM.instance.setDetailData(dateTitle, records);
    }
  }
}

