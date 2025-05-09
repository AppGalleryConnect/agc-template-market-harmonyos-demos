import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { IProductItem, } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { ITransactionItem } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordListResp';

const TAG = '[TransactionSearchVM]';

@ObservedV2
export class TransactionSearchVM {
  private static _instance: TransactionSearchVM;
  @Trace public total: number = 0
  @Trace public transactionList: ITransactionItem[] = []
  @Trace public searchText: string = ''

  public static get instance() {
    if (!TransactionSearchVM._instance) {
      TransactionSearchVM._instance = new TransactionSearchVM();
    }
    return TransactionSearchVM._instance;
  }

  init() {
    RouterModule._stack.setInterception({
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar',
        operation: NavigationOperation, animated: boolean) => {
        if (to === 'navBar') {
          return
        }
        const path = to as NavDestinationContext
        if (path.pathInfo.name === 'TransactionRecordList') {
          this.total = 0
          this.transactionList = []
          this.searchText = ''
        }
      }
    })
  }

  search(value: string) {
    this.getTransactionRecordList(1, value)
  }

  public async getTransactionRecordList(userId: number, searchText?: string) {
    const res = await https.getTransactionList({
      userId,
      searchText,
    });
    if (res.code === 0) {
      this.transactionList = res.data;
    }
  }
}
