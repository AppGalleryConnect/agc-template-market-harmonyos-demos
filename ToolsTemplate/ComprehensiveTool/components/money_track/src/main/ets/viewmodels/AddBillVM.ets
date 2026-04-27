import dayjs from 'dayjs';
import { BalanceChangeType } from '../commons/Enums';
import { BalanceResourceModel, BillManageModel } from '../commons/Models';
import { BalanceResourceItem } from '../commons/Types';
import { ResourceUtil } from '../utils/ResourceUtil';
import { toastUtil } from '../utils/ToastUtil';

@ObservedV2
export class AddBillVM {
  @Trace billData: BillManageModel = new BillManageModel();
  @Trace resource: BalanceResourceModel = ResourceUtil.getResourceList();
  @Trace selectedIndex: number = 0
  scroller:Scroller = new Scroller()

  @Computed
  public get displayResourceList() {
    if (this.billData.type === BalanceChangeType.INCOME) {
      return ResourceUtil.displayIncomeResource;
    }
    return ResourceUtil.displayExpenseResource;
  }

  public handleBillInitialization(bill: BillManageModel) {
    this.billData.type = bill.type;
    this.billData.resource = bill.resource;
    this.billData.amount = bill.amount;
    this.billData.date = bill.date;
    this.billData.note = bill.note;
    this.billData.transactionId = bill.transactionId;
  }

  public handleTypeChange(type: BalanceChangeType) {
    this.billData.type = type;
    if (type === BalanceChangeType.EXPENSE) {
      this.billData.resource = 101;
    } else {
      this.billData.resource = 201;
    }
  }

  public handleResourceChange(item: BalanceResourceItem,index:number) {
    this.selectedIndex = index;
    this.scroller.scrollToIndex(index,true)
    return (this.billData.resource = item.key);
  }

  public handleKeyboardChange(amountArr: string[], note: string, date: Date) {
    let amount: number = 0;
    let operator: string = '';
    let lastAmount: number = 0;
    let flag = false;
    for (let i = 0; i < amountArr.length; i++) {
      let text = amountArr[i];
      if (amountArr[i] === '') {
        continue;
      }
      if (amount === 0 && !flag) {
        amount = Number(text);
        flag = true;
        continue;
      }
      if (Number(text)) {
        lastAmount = Number(text);
      } else {
        operator = text;
      }
      if (lastAmount && operator) {
        if (operator === '+') {
          amount += lastAmount;
        } else if (operator === '-') {
          amount -= lastAmount;
        }
        lastAmount = 0;
        operator = '';
      }
    }
    if (amount < 0) {
      toastUtil.showToast('金额不得小于0，请检查输入~');
      return false;
    } else if (amount > 999999) {
      toastUtil.showToast('金额过大，请检查输入~');
      return false;
    } else {
      this.billData.amount = amount;
      this.billData.note = note;
      this.billData.date = dayjs(date).format('YYYY-MM-DD');
      return true;
    }
  }
}
