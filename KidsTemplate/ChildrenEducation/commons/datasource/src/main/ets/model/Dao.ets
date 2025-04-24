/**
 * 本地持久化的类
 */

@ObservedV2
export class UsedLimit {
  date: number = 20250317;
  usedDuration: number = 0;
  isTimeOut: boolean = false;
}

@ObservedV2
export class VipRecord {
  /**
   * 60 * 24
   */
  timeLimit: number = 1440;
  lunchTimeState: boolean = false;
  nightTimeState: boolean = false;
  lunchStartTime: string = '';
  lunchEndTime: string = '';
  nightStartTime: string = '';
  nightEndTime: string = '';
  isVip: boolean = false;
  validTime: string = '';
  // historyList: ArrayList<History> = new ArrayList();
}