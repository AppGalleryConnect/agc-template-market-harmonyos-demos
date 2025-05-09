import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp';

const TAG = '[FinancialInformationVM]';

@ObservedV2
export class FinancialInformationVM {
  private static _instance: FinancialInformationVM;
  @Trace public noticeList: INoticeItem[] = []

  public static get instance() {
    if (!FinancialInformationVM._instance) {
      FinancialInformationVM._instance = new FinancialInformationVM();
    }
    return FinancialInformationVM._instance;
  }

  async init() {
    this.getNoticeList()
  }


  public async getNoticeList() {
    const res = await https.getNoticeList();
    if (res.code === 0) {
      this.noticeList = res.data;
    }
  }
}
