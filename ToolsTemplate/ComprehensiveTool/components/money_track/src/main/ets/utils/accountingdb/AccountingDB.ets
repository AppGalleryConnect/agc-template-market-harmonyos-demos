import relationalStore from '@ohos.data.relationalStore';
import { BaseDB } from '../basedb/BaseDB';
import { DBOperator } from '../basedb/Constants';
import {
  TableOrderByParams,
  TablePredicateParams,
  TableQueryWithPaginationRsp,
  TableSchema,
} from '../basedb/Types';
import { Logger } from '../Logger';
import { toastUtil } from '../ToastUtil';
import { AccountingDBConstants } from './Constants';
import {
  AccountTableFields,
  TransactionTableFields,
} from './Enums';
import {
  Account,
  AccountTableBasis,
  AmountSummary,
  TransactionReportRsp,
  TransactionTableBasis,
  UserTablePredicateParams,
  UserTransaction,
} from './Types';

const TAG = '[AccountingDB]';

class AccountingDB extends BaseDB {
  protected dbConfig: relationalStore.StoreConfig =
    AccountingDBConstants.DB_CONFIG;
  protected tableSchemas: TableSchema[] = [
    {
      tableName: AccountingDBConstants.ACCOUNT_TABLE_NAME,
      createSQL: AccountingDBConstants.ACCOUNT_TABLE_SQL_CREATE,
      indexes: AccountingDBConstants.ACCOUNT_TABLE_INDEXES_CREATE,
    },
    {
      tableName: AccountingDBConstants.TRANSACTION_TABLE_NAME,
      createSQL: AccountingDBConstants.TRANSACTION_TABLE_SQL_CREATE,
      indexes: AccountingDBConstants.TRANSACTION_TABLE_INDEXES_CREATE,
    },
  ];

  public async initialize(context: Context) {
    await super.initialize(context);
    await this._initDefaultAccounts();
  }

  // 初始化账本
  private async _initDefaultAccounts() {
    const accountTable: AccountTableBasis = {
      accountId: 'default_account',
      name: '默认账本',
      type: 'default',
    };
    const existing = await this.query<Account>(
      AccountingDBConstants.ACCOUNT_TABLE_NAME,
      [
        {
          field: AccountTableFields.NAME,
          operator: DBOperator.EQUAL,
          value: accountTable.name,
        },
        {
          field: AccountTableFields.TYPE,
          operator: DBOperator.EQUAL,
          value: accountTable.type,
        },
      ],
    );

    if (existing.length === 0) {
      await this.insert(AccountingDBConstants.ACCOUNT_TABLE_NAME, accountTable);
      Logger.info(TAG, 'create account table success');
    }
  }

  // 新增交易记录
  public async addTransaction(userTx: UserTransaction): Promise<void> {
    const tx: TransactionTableBasis = {
      transactionId: new Date().getTime(),
      accountId: userTx.accountId,
      type: userTx.type,
      resource: userTx.resource,
      amount: userTx.amount,
      date: userTx.date,
      note: userTx.note,
      excluded: userTx.excluded,
      assetId: userTx.assetId,
    };
    return this.transaction(async () => {
      try {
        await this.insert(AccountingDBConstants.TRANSACTION_TABLE_NAME, tx);
        toastUtil.showToast('交易记录新增成功~');
        Logger.info(TAG, 'insert transaction success.');
      } catch (err) {
        toastUtil.showToast('交易记录新增失败，请稍后重试~');
        Logger.error(
          TAG,
          'insert transaction failed. error:' + JSON.stringify(err),
        );
      }
    });
  }

  // 删除交易记录
  public async deleteTransactions(transactionId: number) {
    const condition: TablePredicateParams = {
      field: TransactionTableFields.TRANSACTION_ID,
      value: transactionId,
      operator: DBOperator.EQUAL,
    };
    try {
      await this.delete(AccountingDBConstants.TRANSACTION_TABLE_NAME, [
        condition,
      ]);
      toastUtil.showToast('删除成功~');
      Logger.info(TAG, 'delete transaction success.');
    } catch (err) {
      toastUtil.showToast('交易记录删除失败，请稍后重试~');
      Logger.error(
        TAG,
        'delete transaction failed. error:' + JSON.stringify(err),
      );
    }
  }

  // 删除相同类型的所有交易记录
  public async deleteTransactionsByResource(resource: number) {
    const condition: TablePredicateParams = {
      field: TransactionTableFields.RESOURCE,
      value: resource,
      operator: DBOperator.EQUAL,
    };
    try {
      const res = await this.delete(
        AccountingDBConstants.TRANSACTION_TABLE_NAME,
        [condition],
      );
      toastUtil.showToast('删除成功~');
      Logger.info(TAG, 'delete transaction success.');
      return res;
    } catch (err) {
      toastUtil.showToast('交易记录删除失败，请稍后重试~');
      Logger.error(
        TAG,
        'delete transaction failed. error:' + JSON.stringify(err),
      );
      return 0;
    }
  }

  // 更新交易记录
  public async updateTransactions(userTx: TransactionTableBasis) {
    const condition: TablePredicateParams = {
      field: TransactionTableFields.TRANSACTION_ID,
      value: userTx.transactionId,
      operator: DBOperator.EQUAL,
    };
    const tx: TransactionTableBasis = {
      transactionId: userTx.transactionId,
      accountId: userTx.accountId,
      type: userTx.type,
      resource: userTx.resource,
      amount: userTx.amount,
      date: userTx.date,
      note: userTx.note,
      excluded: userTx.excluded,
      assetId: userTx.assetId,
    };
    try {
      const res = await this.update<TransactionTableBasis>(
        AccountingDBConstants.TRANSACTION_TABLE_NAME,
        tx,
        [condition],
      );
      if (res === 1) {
        toastUtil.showToast('交易记录更新成功~');
        Logger.info(TAG, 'update transaction success.');
      } else {
        throw new Error(res.toString());
      }
    } catch (err) {
      toastUtil.showToast('交易记录更新失败，请稍后重试~');
      Logger.error(
        TAG,
        'update transaction failed. error:' + JSON.stringify(err),
      );
    }
  }

  // 获取交易记录
  public async getTransactionsWithPagination(
    conditions: UserTablePredicateParams[],
    page: number,
    pageSize: number,
  ): Promise<TableQueryWithPaginationRsp<TransactionTableBasis>> {
    return this.queryWithPagination<TransactionTableBasis>(
      AccountingDBConstants.TRANSACTION_TABLE_NAME,
      conditions,
      page,
      pageSize,
      { field: TransactionTableFields.TRANSACTION_ID, desc: true },
    );
  }

  // 按照指定条件获取交易报表
  public async getTransactions(
    conditions: UserTablePredicateParams[],
  ): Promise<TransactionReportRsp> {
    try {
      return this.transaction<TransactionReportRsp>(async () => {
        const orderBy: TableOrderByParams = {
          field: TransactionTableFields.TRANSACTION_ID,
          desc: true,
        };
        const transactions = await this.query<TransactionTableBasis>(
          AccountingDBConstants.TRANSACTION_TABLE_NAME,
          conditions,
          orderBy,
        );
        const dateCon = conditions.find(
          (item) => item.field === TransactionTableFields.DATE,
        );
        const resourceCon = conditions.find(
          (item) => item.field === TransactionTableFields.RESOURCE,
        );
        const sql = `
        SELECT
           SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as totalIncome,
           SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as totalExpense
        FROM transactions
           WHERE date like '${dateCon ? dateCon.value : ''}%'
           ${resourceCon ? 'AND resource = ' + resourceCon.value : ''}`;
        const summary = await this.querySql<AmountSummary>(sql);
        const res: TransactionReportRsp = {
          transactions,
          totalIncome: summary[0]?.totalIncome ?? 0,
          totalExpense: summary[0]?.totalExpense ?? 0,
        };
        return res;
      });
    } catch (err) {
      Logger.error(
        TAG,
        'get transactions failed. error:' + JSON.stringify(err),
      );
      const res: TransactionReportRsp = {
        transactions: [],
        totalIncome: 0,
        totalExpense: 0,
      };
      return res;
    }
  }
}

const accountingDB = new AccountingDB();

export { accountingDB as AccountingDB };
