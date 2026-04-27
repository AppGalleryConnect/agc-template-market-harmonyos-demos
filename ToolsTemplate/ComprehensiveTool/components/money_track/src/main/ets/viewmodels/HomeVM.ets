import { UtilLog } from '@hw-agconnect/util-log';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import dayjs from 'dayjs';
import { BillConstants, HomeConstants } from '../commons/Constants';
import { BalanceChangeType, DialogMap, HomeSheetType, RouterMap, SummaryType } from '../commons/Enums';
import { BalanceResourceModel, DailyBillGroupModel, HomeSheetModel } from '../commons/Models';
import { DialogInfo, ConfirmParam, ConfirmDialogOption,
  BillBarChartData,
  BillBarItem,
  BillPieChartItem,
  ReportTableItem,
  BillByResourceRouteParams} from '../commons/Types';
import { AccountingDB } from '../utils/accountingdb/AccountingDB';
import { EventBus, EventKey } from '../utils/EventBus';
import { ResourceUtil } from '../utils/ResourceUtil';
import { BillProcessingModel } from './BillProcessingModel';

@ObservedV2
export class HomeVM {
  @Trace checkedType: BalanceChangeType = BalanceChangeType.INCOME;
  @Trace checkedResource: number = HomeConstants.RESOURCE_NO_FILTER;
  @Trace resource: BalanceResourceModel = ResourceUtil.getResourceList();
  @Trace showSheet: boolean = true;
  @Trace sheet: HomeSheetModel = new HomeSheetModel();
  @Trace listData: BillProcessingModel = new BillProcessingModel();
  @Trace chartData:BillProcessingModel = new BillProcessingModel();
  @Trace stack:NavPathStack = new NavPathStack()
  @Trace summaryType: SummaryType = SummaryType.LIST;
  @Trace chartType: BalanceChangeType = BalanceChangeType.EXPENSE;
  @Trace selectedDateData: DailyBillGroupModel = new DailyBillGroupModel();

  @Computed
  public get summaryLabel() {
    if (this.summaryType === SummaryType.LIST) {
      return '明细';
    }
    return '统计图表';
  }

  @Computed
  public get pieChartData(): BillPieChartItem[] {
    const map: Map<number, number> = new Map();
    if (this.chartData.bill) {
      this.chartData.bill.transactions.forEach((item) => {
        let preAmount = map.get(item.resource) ?? 0;
        if (item.type === this.chartType) {
          map.set(item.resource, preAmount + item.amount);
        }
      });
      const tempList: (BillPieChartItem | undefined)[] = Array.from(map).map(
        (item) => {
          const resource = ResourceUtil.getResourceItem(item[0]);
          if (!resource) {
            return undefined;
          }
          const pieItem: BillPieChartItem = {
            resource: resource.key,
            label: resource.name,
            value: item[1],
          };
          return pieItem;
        },
      );
      const list = tempList.filter(
        (item) => typeof item !== 'undefined',
      ) as BillPieChartItem[];
      return list;
    }
    return [];
  }

  @Computed
  public get pieChartColor(): number[] {
    if (this.chartType === BalanceChangeType.EXPENSE) {
      return BillConstants.EXPENSE_COLOR_LIST;
    }
    return BillConstants.INCOME_COLOR_LIST;
  }

  @Computed
  public get barChartData(): BillBarChartData {
    const data: BillBarItem[] = [];
    if (this.chartData.list) {
      this.chartData.list.forEach((item) => {
        const amount: number = item.list
          .filter((bill) => bill.type === this.chartType)
          .reduce((pre, bill) => pre + bill.amount, 0);
        const barItem: BillBarItem = {
          date: dayjs(item.list[0].date).format('YYYY-MM-DD'),
          value: amount,
        };
        data.push(barItem);
      });
    }
    return {
      month: this.chartData.date,
      data,
      typeLabel: this.chartType === BalanceChangeType.EXPENSE ? '支出' : '收入',
    };
  }

  @Computed
  public get reportData() {
    const data: ReportTableItem[] = [];
    if (this.chartData.list) {
      this.chartData.list.forEach((item) => {
        const date = item.dateStr;
        const totalIncome = item.list
          .filter((bill) => bill.type === BalanceChangeType.INCOME)
          .reduce((pre, bill) => pre + bill.amount, 0);
        const totalExpense = item.list
          .filter((bill) => bill.type === BalanceChangeType.EXPENSE)
          .reduce((pre, bill) => pre + bill.amount, 0);
        const reportItem: ReportTableItem = {
          date,
          totalIncome,
          totalExpense,
        };
        data.push(reportItem);
      });
    }
    return data;
  }

  @Computed
  public get barInitColor() {
    return this.chartType === BalanceChangeType.EXPENSE
      ? BillConstants.EXPENSE_BAR_INIT_COLOR
      : BillConstants.INCOME_BAR_INIT_COLOR;
  }

  @Computed
  public get barHighlightColor() {
    return this.chartType === BalanceChangeType.EXPENSE
      ? BillConstants.EXPENSE_BAR_HIGHLIGHT_COLOR
      : BillConstants.INCOME_BAR_HIGHLIGHT_COLOR;
  }
  @Computed
  public get currentResourceItem() {
    if (this.checkedResource === HomeConstants.RESOURCE_NO_FILTER) {
      return null;
    }
    let list =
      this.checkedType === BalanceChangeType.INCOME
        ? this.resource.income
        : this.resource.expense;
    const item = Array.from(list).find(
      (item) => item.key === this.checkedResource,
    );
    return item;
  }

  @Computed
  public get resourceLabel() {
    return this.currentResourceItem?.name ?? '全部类型';
  }

  public async initData(stack:NavPathStack, uiContext: UIContext) {
    this.stack = stack
    await AccountingDB.initialize(uiContext.getHostContext()!);
    await this.refreshBill();
    EventBus.instance.on(EventKey.GLOBAL_REFRESH_EVENT, () => {
      this.refreshBill();
    });
  }

  public openSheet(type: HomeSheetType) {
    this.sheet.type = type;
    if (type === HomeSheetType.DATE) {
      this.sheet.sheetHeight = 360;
      this.sheet.title = '选择月份';
    } else if (type === HomeSheetType.TYPE) {
      this.sheet.sheetHeight = 540;
      this.sheet.title = '选择类型';
    }
  }

  public async refreshBill() {
    this.listData.getBillReport(this.checkedResource);
    this.chartData.getBillReport()
    try {
      emitter.emit({ eventId: 1 });
    } catch (e) {
      UtilLog.error(`refreshBill failed with `)
    }
  }

  public async deleteBill(id: number, uiContext: UIContext) {
    this.stack.pushPath({
      name: DialogMap.COMMON_CONFIRM,
      param: {
        message: '删除后账单无法恢复，是否确认删除？',
      } as ConfirmDialogOption,
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm) {
          await AccountingDB.deleteTransactions(id);
          uiContext.getPromptAction().showToast({ message: '账单删除成功~' });
          EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
        }
      },
    });
  }

  public async changeMonth(dateStr: string) {
    this.listData.changeMonth(dateStr);
    this.chartData.changeMonth(dateStr)
    await this.refreshBill();
  }

  public async changeResource(type: BalanceChangeType, key: number) {
    this.checkedType = type;
    this.checkedResource = key;
    await this.refreshBill();
  }


  public async changeChartType(type: BalanceChangeType) {
    this.chartType = type;
  }

  public jumpToDetailPage(resource: number) {
    this.stack.pushPath({
      name: RouterMap.STATISTICS_BILL_BY_RESOURCE,
      param: {
        resource,
        date: this.listData.date,
      } as BillByResourceRouteParams,
    });
  }
}
