export interface IPositionInfo {
  id: number,
  productId: number,
  productName: string, //产品名称
  productNumber: string, //产品代码

  positionSize: number, //持仓份额
  positionMarket: number, //持仓市值
  positionAmount: number, //持有金额
  toBeConfirmedAmount: number, //待确认金额
  positionCostPrice: number, //持仓成本价
  dailyRate: number, //日涨幅
  netValue: number, //净值
  payoutDate: string, //收益日期
  dailyProfitAndLoss: number, //每日盈亏
  positionProfit: number, //持仓收益
  allProfitAndLoss: number, //累计盈亏
  dividendDistributionMethod: string, //分红方式

  isRedemption: boolean, //是否可以赎回
  redemptionTime: number, //赎回时间
  redemptionSize: number, //赎回份额
  redemptionApplicationDate: string, //赎回日期
  redemptionApplicationConfirmDate: string, //赎回申请确认日期
  fundsReceivedDate: string, //到账日期
  redemptionTip: string, //提示
}

export interface IPositionRecord {
  id: number,
  type: number,
  date: string,
  time: string,
  amount: number,
  state: number
}

export type GetPositionInfoResp = IPositionInfo