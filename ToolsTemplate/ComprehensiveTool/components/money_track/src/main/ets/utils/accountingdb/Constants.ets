import { relationalStore } from '@kit.ArkData';

export class AccountingDBConstants {
  public static readonly DB_CONFIG: relationalStore.StoreConfig = {
    name: 'AccountingApp.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  public static readonly ACCOUNT_TABLE_NAME: string = 'accounts';
  public static readonly ACCOUNT_TABLE_SQL_CREATE: string = `CREATE TABLE IF NOT EXISTS accounts (
    accountId INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK(type IN ('default')),
    balance REAL DEFAULT 0
  )`;
  public static readonly ACCOUNT_TABLE_INDEXES_CREATE: string[] = [
    'CREATE INDEX IF NOT EXISTS index_type ON accounts (type)',
  ];
  public static readonly TRANSACTION_TABLE_NAME: string = 'transactions';
  public static readonly TRANSACTION_TABLE_SQL_CREATE: string = `CREATE TABLE IF NOT EXISTS transactions (
    transactionId INTEGER PRIMARY KEY AUTOINCREMENT,
    accountId INTEGER NOT NULL,
    assetId INTEGER DEFAULT NULL,
    type TEXT CHECK(type IN ('income', 'expense')),
    resource INTEGER NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    note TEXT DEFAULT '',
    excluded BOOLEAN DEFAULT true,
    FOREIGN KEY (accountId) REFERENCES accounts(accountId) ON DELETE CASCADE,
    FOREIGN KEY (assetId) REFERENCES assets(assetId) ON DELETE CASCADE
  )`;
  public static readonly TRANSACTION_TABLE_INDEXES_CREATE: string[] = [
    'CREATE INDEX IF NOT EXISTS index_type ON transactions (type)',
    'CREATE INDEX IF NOT EXISTS index_resource ON transactions (resource)',
    'CREATE INDEX IF NOT EXISTS index_date ON transactions (date)',
  ];
}
