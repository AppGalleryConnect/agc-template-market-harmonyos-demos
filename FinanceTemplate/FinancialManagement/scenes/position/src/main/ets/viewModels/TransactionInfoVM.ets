import { https } from 'network';
import { RouterMap, RouterModule, } from 'commonlib';
import { ITransactionInfo, State } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordInfoResp';
import { OrderDetailBean } from 'componentlib'

const TAG = '[TransactionInfoVM]';

@ObservedV2
export class TransactionInfoVM {
  private static _instance: TransactionInfoVM;
  @Trace public transactionInfo: ITransactionInfo | undefined
  @Trace public timeLineList: OrderDetailBean[] = []
  @Trace public totalSize: number = 3

  public static get instance() {
    if (!TransactionInfoVM._instance) {
      TransactionInfoVM._instance = new TransactionInfoVM();
    }
    return TransactionInfoVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.TRANSACTION_RECORD_INFO,
    });
    if (param) {
      this.getTransactionRecordInfo(param)
    }
  }

  clear() {
    this.transactionInfo = undefined
    this.timeLineList = []
  }

  public async getTransactionRecordInfo(id: number) {
    const res = await https.getTransactionRecordInfo(id);
    if (res.code === 0) {
      this.transactionInfo = res.data;
      if (this.transactionInfo.state === State.IN_PROGRESS && this.transactionInfo.type === 2 &&
      this.transactionInfo.status) {
        this.totalSize = 3
        this.transactionInfo.status.forEach((item) => {
          const timeLine: OrderDetailBean = {
            nodeStatus: item.status,
            nodeTime: item.date
          }
          this.timeLineList.push(timeLine)
        })
        this.timeLineList[0].nodeName = '提出购买申请'
        this.timeLineList[0].nextNodeStatus = this.transactionInfo.status[1].status
        this.timeLineList[1].nodeName = '扣款'
        this.timeLineList[1].nextNodeStatus = this.transactionInfo.status[2].status
        this.timeLineList[2].nodeName = '确认份额'
      }

      if (this.transactionInfo.state === State.IN_PROGRESS && this.transactionInfo.type === 3 &&
      this.transactionInfo.status) {
        this.totalSize = 2
        this.transactionInfo.status.forEach((item) => {
          const timeLine: OrderDetailBean = {
            nodeStatus: item.status,
            nodeTime: item.date
          }
          this.timeLineList.push(timeLine)
        })
        this.timeLineList[0].nodeName = '提交赎回申请，份额冻结'
        this.timeLineList[0].nextNodeStatus = this.transactionInfo.status[1].status
        this.timeLineList[1].nodeName = '资金到账'
      }
    }
  }
}
