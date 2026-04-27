import { BalanceChangeType, RouterMap, DialogMap } from '../commons/Enums';
import { BillCardItemModel } from '../commons/Models';
import { BillCardItem, ConfirmDialogOption, ConfirmParam, DialogInfo } from '../commons/Types';
import { AccountingDB } from '../utils/accountingdb/AccountingDB';
import { UserTransaction } from '../utils/accountingdb/Types';
import { BillManageUtil } from '../utils/BillManageUtil';
import { EventBus, EventKey } from '../utils/EventBus';
import { Logger } from '../utils/Logger';
import { ResourceUtil } from '../utils/ResourceUtil';
import { toastUtil } from '../utils/ToastUtil';

const TAG = '[BillDetailVM]';

@ObservedV2
export class BillDetailVM {
  @Trace stack: NavPathStack = new NavPathStack()
  @Trace bill: BillCardItemModel = new BillCardItemModel();

  @Computed
  public get isIncome() {
    return Boolean(this.bill?.type === BalanceChangeType.INCOME);
  }

  public initData(stack: NavPathStack) {
    this.stack = stack;
    const param = this.stack.getParamByName(RouterMap.HOME_BILL_DETAIL) as BillCardItem[] | undefined
    if (param?.length) {
      const data = param[0]
      this.bill.accountId = data.accountId;
      this.bill.transactionId = data.transactionId;
      this.bill.resource = data.resource;
      this.bill.icon = data.icon;
      this.bill.title = data.title;
      this.bill.note = data.note;
      this.bill.amount = data.amount;
      this.bill.type = data.type;
      this.bill.date = data.date;
    }
  }

  public deleteBill() {
    this.stack.pushPath({
      name: DialogMap.COMMON_CONFIRM,
      param: {
        message: '删除后账单无法恢复，是否确认删除？',
      } as ConfirmDialogOption,
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm && this.bill) {
          await AccountingDB.deleteTransactions(this.bill.transactionId);
          toastUtil.showToast('账单删除成功~');
          EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
          this.stack.pop(1)
        }
      },
    });
  }

  public editBill() {
    BillManageUtil.manageBill(this.bill, undefined, (data: UserTransaction) => {
      try {
        const resourceItem = ResourceUtil.getResourceItem(data.resource);
        this.bill.accountId = this.bill.accountId;
        this.bill.transactionId = this.bill.transactionId;
        this.bill.date = data.date;
        this.bill.resource = resourceItem.key;
        this.bill.title = resourceItem.name;
        this.bill.icon = resourceItem.icon;
        this.bill.amount = data.amount;
        this.bill.type = data.type;
        this.bill.note = data.note;
        EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
      } catch (error) {
        Logger.error(TAG, 'edit bill failed.error:' + JSON.stringify(error));
      }
    });
  }
}
