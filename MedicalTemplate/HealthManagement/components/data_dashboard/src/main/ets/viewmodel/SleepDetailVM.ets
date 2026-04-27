/**
 * 睡眠历史详情 ViewModel
 */
import { SleepRecord } from '../types/SleepTypes';

@ObservedV2
export class SleepDetailVM {
  private static _instance: SleepDetailVM;
  @Trace dateTitle: string = '4月28日';
  @Trace records: SleepRecord[] = [
    { label: '睡眠', value: '8小时30分钟' },
    { label: '开始时间', value: '2025/4/28 22:30' },
    { label: '结束时间', value: '2025/4/29 07:00' }
  ];

  public static get instance(): SleepDetailVM {
    if (!SleepDetailVM._instance) {
      SleepDetailVM._instance = new SleepDetailVM();
    }
    return SleepDetailVM._instance;
  }

  /**
   * 设置详情数据
   */
  public setDetailData(date: string, records: SleepRecord[]): void {
    this.dateTitle = date;
    this.records = records;
  }
}

