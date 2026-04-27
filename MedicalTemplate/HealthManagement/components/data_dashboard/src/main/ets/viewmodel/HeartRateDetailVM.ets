/**
 * 心率历史详情 ViewModel
 */
import { HeartRateRecord } from '../types/HeartRateTypes';
import { HEART_RATE_DETAIL_RECORDS } from '../mock/HeartRateMockData';

@ObservedV2
export class HeartRateDetailVM {
  private static _instance: HeartRateDetailVM;
  @Trace dateTitle: string = '4月28日';
  @Trace records: HeartRateRecord[] = HEART_RATE_DETAIL_RECORDS;

  public static get instance(): HeartRateDetailVM {
    if (!HeartRateDetailVM._instance) {
      HeartRateDetailVM._instance = new HeartRateDetailVM();
    }
    return HeartRateDetailVM._instance;
  }

  /**
   * 设置详情数据
   */
  public setDetailData(date: string, records: HeartRateRecord[]): void {
    this.dateTitle = date;
    this.records = records;
  }
}

