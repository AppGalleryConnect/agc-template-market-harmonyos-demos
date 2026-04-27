export const enum LoanType {
  // 商业贷款
  Commercial,
  // 公积金贷款
  ProvidentFund,
  // 组合贷款
  Combination,
}

export const enum LoanPayType {
  // 等额本息
  EqualInterestPay,
  // 等额本金
  EqualPrincipalPay,
}

@ObservedV2
export class AreaType {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

export interface FundLoanParams {
  type: LoanType;
  payType: LoanPayType;
  rate: number,
  year: number,
  cost: number,
  fundRate: number,
  fundYear: number,
  fundCost: number,
}

export interface LoanParams {
  type: LoanType;
  payType: LoanPayType;
  rate: number,
  year: number,
  cost: number,
}

export interface MonthlyRepayment {
  periodNum: number;
  monthPay: number;
  monthPrincipal: number;
  monthInterest: number;
  remainingPrincipal: number;
}

export interface LoanCalculationResult {
  cost: number;
  year: number;
  rate: number;
  totalPay: number;
  totalInterest: number;
  monthDetail: Array<MonthlyRepayment>
}

export interface CombinationOptions {
  rate: number;
  year: number;
  cost: number;
  fundRate: number;
  fundYear: number;
  fundCost: number;
  type: LoanPayType;
}

export interface MonthlyCombinationRepayment {
  periodNum: number;
  monthPay: number;
  commercialMonthPay: number;
  fundMonthPay: number;
}

export interface CombinationCalculationResult {
  cost: number;
  year: number;
  totalPay: number;
  totalInterest: number;
  monthDetail: Array<MonthlyCombinationRepayment>
}

@ObservedV2
export class ResultParams {
  @Trace rate: number = 0;
  @Trace year: number = 0;
  @Trace cost: number = 0;
}

export class LoanPrimeRate {
  date: string = '';
  one: string = '';
  five: string = '';
}
