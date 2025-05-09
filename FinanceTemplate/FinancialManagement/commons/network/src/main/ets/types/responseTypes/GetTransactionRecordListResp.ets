export interface ITransactionItem {
  id: number,
  type: number, //交易类型
  amount: number, //交易金额
  share: number, //交易份额
  date: string, //购买时间
  productName: string, //产品名称
  bankCardNo: string,
}

export interface IMonthTransactionItem {
  month: string,
  transactionList: ITransactionItem[]
}

export type GetTransactionRecordListResp = ITransactionItem[]

export type GetMonthTransactionRecordListResp = IMonthTransactionItem[]

