import { DepositType, FinancialType } from '../common/Constant'

@ObservedV2
export class InvestmentDetail {
  // 理财类型
  @Trace financialType: FinancialType = FinancialType.BANK
  // 是否开启计算按钮
  @Trace isShowButton: boolean = false
  // 是否显示结果
  @Trace isShowRes: boolean = false
  // 存款类型：如活期、定期
  @Trace type: number = DepositType.CURRENT
  // 存款金额
  @Trace money: string = ''
  // 存款年限
  @Trace time: string = ''
  // 存款利率
  @Trace rate: string = ''
  // 年复利次数
  @Trace compoundRateCount: string = ''
  // 每月定投金额
  @Trace monthlyMoney: string = ''
  // 总收益
  @Trace totalRevenue: number = 0
  // 利息收益
  @Trace rateRevenue: number = 0
  // 月均收益
  @Trace monthlyRevenue: number = 0

  constructor(financialType: FinancialType) {
    this.financialType = financialType
  }
}

export interface ProfitDetail {
  totalRevenue: number
  rateRevenue: number
  monthlyRevenue: number
}