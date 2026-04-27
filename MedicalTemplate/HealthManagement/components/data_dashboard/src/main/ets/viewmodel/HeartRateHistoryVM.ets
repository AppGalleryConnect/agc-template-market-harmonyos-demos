/**
 * 心率历史记录 ViewModel
 */
import { MonthGroup, SimpleMenuItem, HeartRateHistoryItem, HeartRateRecord } from '../types/HeartRateTypes';
import { HEART_RATE_HISTORY_MONTHS } from '../mock/HeartRateMockData';
import { HeartRateDetailVM } from './HeartRateDetailVM';

@ObservedV2
export class HeartRateHistoryVM {
  private static _instance: HeartRateHistoryVM;
  @Trace months: MonthGroup[] = HEART_RATE_HISTORY_MONTHS;
  @Trace selectedMonthIndex: number = 0;
  @Trace showMonthMenu: boolean = false;

  public static get instance(): HeartRateHistoryVM {
    if (!HeartRateHistoryVM._instance) {
      HeartRateHistoryVM._instance = new HeartRateHistoryVM();
    }
    return HeartRateHistoryVM._instance;
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
          this.selectedMonthIndex = index;
          this.showMonthMenu = false;
        }
      });
    }
    return items;
  }

  /**
   * 设置详情页数据
   */
  public setDetailData(item: HeartRateHistoryItem): void {
    // 从dateTime中提取日期，格式如"4月28日"
    const dateTitle = item.dateTime;

    // 从range中提取最低和最高心率，格式如"56 ~ 121次/分钟"
    const rangeMatch = item.range.match(/(\d+)\s*~\s*(\d+)/);
    if (rangeMatch) {
      const minRate = parseInt(rangeMatch[1]);
      const maxRate = parseInt(rangeMatch[2]);

      // 生成一天中多个时间点的心率记录
      const records: HeartRateRecord[] = [
        { value: `${maxRate}次/分钟`, time: '18:27' },
        { value: `${Math.floor((maxRate + minRate) / 2 + 10)}次/分钟`, time: '15:22' },
        { value: `${Math.floor((maxRate + minRate) / 2)}次/分钟`, time: '12:00' },
        { value: `${Math.floor((maxRate + minRate) / 2 - 5)}次/分钟`, time: '09:34' },
        { value: `${minRate + 10}次/分钟`, time: '08:12' },
        { value: `${minRate}次/分钟`, time: '07:34' }
      ];

      HeartRateDetailVM.instance.setDetailData(dateTitle, records);
    }
  }
}

