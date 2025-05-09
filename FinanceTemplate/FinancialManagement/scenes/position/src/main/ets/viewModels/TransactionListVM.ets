import { https } from 'network';
import { AccountUtil, UserInfoModel } from 'commonlib';
import { IMonthTransactionItem, } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordListResp';
import { ISettingData } from 'network/src/main/ets/mocks/Constants';

const TAG = '[TransactionListVM]';

@ObservedV2
export class TransactionListVM {
  private static _instance: TransactionListVM;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace public transactionRecordList: IMonthTransactionItem[] = []
  @Trace public transactionTypeList: ISettingData[] = []
  @Trace public transactionDateList: ISettingData[] = []
  // 页面数据
  @Trace public selectTransactionTypeList: SelectOption[] = []
  @Trace public selectTransactionDateList: SelectOption[] = []
  @Trace public searchText: string = ''
  @Trace public transactionType: number = 1
  @Trace public transactionDate: number = 1
  @Trace public isSelecting: boolean = false

  public static get instance() {
    if (!TransactionListVM._instance) {
      TransactionListVM._instance = new TransactionListVM();
    }
    return TransactionListVM._instance;
  }

  init() {
    this.getTransactionTypeList()
    this.getTransactionDateList()
    this.getMonthTransactionList(this.userInfo.id, '', this.transactionType, this.transactionDate)
  }

  search() {
    this.getMonthTransactionList(this.userInfo.id, '', this.transactionType, this.transactionDate)
  }

  reset() {
    this.transactionType = 1
    this.transactionDate = 1
    this.search()
  }

  clear() {
    this.selectTransactionTypeList = []
    this.selectTransactionDateList = []
  }

  public async getMonthTransactionList(userId: number, searchText?: string, transactionType?: number,
    transactionDate?: number) {
    const res = await https.getMonthTransactionList({
      userId,
      searchText,
      transactionType,
      transactionDate
    });
    if (res.code === 0) {
      this.transactionRecordList = res.data;
    }
  }

  public async getTransactionTypeList() {
    const res = await https.getTransactionTypeList();
    if (res.code === 0) {
      this.transactionTypeList = res.data;
      this.transactionTypeList.forEach((item) => {
        const data: SelectOption = {
          value: item.label
        }
        this.selectTransactionTypeList.push(data)
      })
    }
  }

  public async getTransactionDateList() {
    const res = await https.getTransactionDateList();
    if (res.code === 0) {
      this.transactionDateList = res.data;
      this.transactionDateList.forEach((item) => {
        const data: SelectOption = {
          value: item.label
        }
        this.selectTransactionDateList.push(data)
      })
    }
  }

  public getLabel(arr: ISettingData[], value: number): string {
    const saleType = arr.find((item) => {
      return item.value === value
    })
    if (saleType) {
      return saleType.label
    }
    return ''
  }

  public getValue(arr: ISettingData[], label: string): number {
    const saleType = arr.find((item) => {
      return item.label === label
    })
    if (saleType) {
      return saleType.value
    }
    return 1
  }
}
