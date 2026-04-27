import { BalanceChangeType, CustomKeyboardButtonType, CustomKeyboardDisplayType, DialogMap } from './Enums';

export interface HomeSheetItem {
  id: number;
  sheetHeight: Length;
  title: string;
}

export interface BillCardItem {
  accountId: number;
  date: string;
  transactionId: number;
  resource: number;
  icon: ResourceStr;
  title: string;
  note?: string;
  amount: number;
  type: BalanceChangeType;
  assetId?: number;
  assetName?: string;
}

export interface DailyBillGroup {
  dateStr: string;
  list: BillCardItem[];
}

export interface BalanceResourceItem {
  key: number;
  name: string;
  icon: ResourceStr;
  uncheckedIcon: ResourceStr;
  type: BalanceChangeType;
  sortNum: number;
  isCustom?: number;
}

export interface DialogInfo<T = Object | undefined> {
  name?: DialogMap;
  param?: T;
  onPop?: Callback<PopInfo>;
}

export interface ConfirmDialogOption {
  title?: string;
  message: string;
}

export interface ConfirmParam {
  isConfirm: boolean;
}

export interface CustomKeyboardItem {
  display: CustomKeyboardDisplayType;
  type: CustomKeyboardButtonType;
  text: string;
  icon?: ResourceStr;
  bgColor?: ResourceColor;
  fontColor?: ResourceColor;
}

export interface BillBarItem {
  date: string;
  value: number;
}

export interface BillBarChartData {
  data: BillBarItem[];
  month: string;
  typeLabel?: string;
}

export interface BillPieChartItem {
  label: string;
  value: number;
  resource: number;
}

export interface BillRankingItem extends BillPieChartItem {
  barLength: Length;
  color: ResourceColor;
}

export interface ReportTableItem {
  date: string;
  totalIncome: number;
  totalExpense: number;
}

export interface BillByResourceRouteParams {
  resource: number;
  date: string;
}
