import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { IRevenueInfo } from 'network/src/main/ets/types/responseTypes/GetRevenueInfoResp';

const TAG = '[RevenueInfoVM]';

@ObservedV2
export class RevenueInfoVM {
  private static _instance: RevenueInfoVM;
  @Trace public revenueInfo: IRevenueInfo | undefined

  public static get instance() {
    if (!RevenueInfoVM._instance) {
      RevenueInfoVM._instance = new RevenueInfoVM();
    }
    return RevenueInfoVM._instance;
  }

  init() {
    this.getRevenueInfo(1, 1)
  }

  public async getRevenueInfo(userId: number, id: number) {
    const res = await https.getRevenueInfo(userId, id);
    if (res.code === 0) {
      this.revenueInfo = res.data;
    }
  }

  public getWidth(revenue: number): string {
    if (revenue === 0) {
      return '50%'
    } else {
      return `${50 + revenue}%`
    }
  }
}
