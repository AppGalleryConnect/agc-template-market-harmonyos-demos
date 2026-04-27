export enum AccountTableFields {
  ACCOUNT_ID = 'accountId',
  NAME = 'name',
  TYPE = 'type',
}

export enum TransactionTableFields {
  TRANSACTION_ID = 'transactionId',
  ACCOUNT_ID = 'accountId',
  ASSET_ID = 'assetId',
  TYPE = 'type',
  RESOURCE = 'resource',
  AMOUNT = 'amount',
  DATE = 'date',
  NOTE = 'note',
  EXCLUDED = 'excluded',
}
