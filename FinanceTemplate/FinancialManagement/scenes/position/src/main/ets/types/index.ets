import {
  IInvestmentRecordItem,
  IRegularInvestmentInfo } from 'network/src/main/ets/types/responseTypes/GetRegularInvestmentResp';

export interface IRedemptionButton {
  index: number,
  text: string,
}

export interface IInvestmentParam {
  investmentInfo: IRegularInvestmentInfo,
  record: IInvestmentRecordItem,
}