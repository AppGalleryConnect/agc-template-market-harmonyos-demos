import { BalanceChangeType } from '../../commons/Enums';
import { TablePredicateParams } from '../basedb/Types';
import {
  AccountTableFields,
  TransactionTableFields,
} from './Enums';

export interface UserTransaction {
  accountId: number;
  transactionId?: number;
  type: BalanceChangeType;
  resource: number;
  amount: number;
  date: string; // yyyy-mm-dd
  note?: string;
  excluded?: boolean;
  assetId?: number;
}

export interface UserTablePredicateParams extends TablePredicateParams {
  field: AccountTableFields | TransactionTableFields;
}

export interface AccountingResource {
  name: string;
  key: number;
}

export interface AccountTableBasis {
  accountId: string;
  name: string;
  type: string;
}

export interface Account {
  accountId: number;
  name: string;
  type: string;
  balance: number;
}

export interface TransactionTableBasis extends UserTransaction {
  transactionId: number;
}

export interface AmountSummary {
  totalIncome: number;
  totalExpense: number;
}

export interface TransactionReportRsp extends AmountSummary {
  transactions: TransactionTableBasis[];
}