import dayjs from 'dayjs';
import { BalanceChangeType, RouterMap } from '../commons/Enums';
import { BalanceResourceItem, BillByResourceRouteParams } from '../commons/Types';
import { ResourceUtil } from '../utils/ResourceUtil';
import { BillProcessingModel } from './BillProcessingModel';

@ObservedV2
export class BillByResourceVM {
  @Trace
  dataProcessing: BillProcessingModel = new BillProcessingModel();
  @Trace
  resourceItem: BalanceResourceItem | undefined = undefined;

  @Computed
  public get summaryLabel() {
    if (!this.resourceItem) {
      return '';
    }
    const dateStr = dayjs(this.dataProcessing.date).format('M月');
    const typeStr =
      this.resourceItem.type === BalanceChangeType.EXPENSE ? '支出' : '收入';
    return dateStr + this.resourceItem.name + '共' + typeStr;
  }

  @Computed
  public get summaryAmount() {
    if (this.resourceItem?.type === BalanceChangeType.EXPENSE) {
      return this.dataProcessing.bill?.totalExpense?.toFixed(2) ?? '0.00';
    } else if (this.resourceItem?.type === BalanceChangeType.INCOME) {
      return this.dataProcessing.bill?.totalIncome?.toFixed(2) ?? '0.00';
    }
    return '0.00';
  }

  public initData(params:BillByResourceRouteParams) {
    if (params) {
      this.dataProcessing.getBillReport(params.resource, params.date);
      this.resourceItem = ResourceUtil.getResourceItem(params.resource);
    }
  }
}
