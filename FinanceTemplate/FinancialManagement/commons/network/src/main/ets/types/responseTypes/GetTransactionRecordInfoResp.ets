export enum State {
  IN_PROGRESS = 1,
  SUCCESS = 2,
  FAILURE = 3,
  TERMINATE = 4
}

export interface ITransactionStatus {
  date: string,
  status: number,
}

export interface ITransactionInfo {
  id: number,
  type: number, //交易类型
  state: State,
  amount: number, //交易金额
  date: string, //交易日期
  productName: string, //产品名称
  productNumber: string, //产品代码
  bankCardNumber: string, //银行卡账号
  status?: ITransactionStatus[], //当交易进行中时，设置交易状态
  msg?: string,
}

export type GetTransactionRecordInfoResp = ITransactionInfo