import { ITransactionStatus } from './GetTransactionRecordInfoResp'

export interface IRegularInvestmentItem {
  id: number,
  productName: string,
  productNumber: string,
  state: number,
  money: number,
  times: number,
  date: string,
  amount: number,
  bankCardNo: string,
}

export interface IInvestmentRecordItem {
  id: number,
  date: string,
  money: number,
  state: number,
  message: string,
}

export interface IRegularInvestmentInfo {
  id: number,
  productName: string,
  productNumber: string,
  state: number,
  amount: number,
  times: number,
  date: string,
  money: number,
  bankCardNo: string,
  status: ITransactionStatus[],
}

export type GetRegularInvestmentListResp = IRegularInvestmentItem[]

export type GetRegularInvestmentInfoResp = IRegularInvestmentInfo

export type GetInvestmentRecordListResp = IInvestmentRecordItem[]