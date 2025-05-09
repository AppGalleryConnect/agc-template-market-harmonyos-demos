export enum ProductType {
  CASH_MANAGEMENT = 1,
  STABLE_LOW_VOLATILITY = 2,
  STABLE_GROWTH = 3,
  STEADY_PROGRESS = 4,
  ENTERPRISING_INVESTMENT = 5,
}

export enum SectionLabel {
  FLEXIBLE_ACCESS = 1,
  FINANCIAL_NIGHT_MARKET = 2
}

export enum SaleState {
  FOR_SALE = 1,
  PRE_SALE = 2,
  SOLD_OUT = 3,
}

export interface IProductType {
  id: number,
  name: string,
  description: string,
}

export interface IProductItem {
  id: number, //产品id
  name: string, //产品名称
  number: string, //产品代码
  type: number, //产品类型
  saleType: SaleState, //产品售卖状态
  redemptionCycle: string, //赎回周期
  annualizedRate: number, //收益率
  annualizedCycle: string, //收益周期
  tip: string, //提示
  risk: string, //风险
  title: string, //标题
  minimumPurchaseAmount: number, //最低购买金额
  eachCost: number, //每一份多少钱
  performanceExplanation?: string, //业绩说明
}

export interface IHistoricalPerformance {
  cycle: string,
  risePrice: number,
  fallingPrice: number,
  annualized: number,
  date: string,
}

export interface IProfile {
  type: string,
  contract: string,
  information: string,
  managementCompany: string,
  number: string,
  date: string,
}

export interface IBuyRule {
  id: number,
  purchaseRate: number,
  subscriptionRate: number,
  date: string,
  minimumPurchaseAmount: number,
  minimumHoldingShare: number,
  pricePerShare: number,
}

export interface IRedemptionRule {
  id: number,
  redemptionRate: number,
  date: string,
  minimumRedemptionAmount: number,
  minimumRedemptionShare: number,
}

export interface IProcess {
  id: number
  confirmationDate: string,
  redemptionDate: string,
}

export interface IDatasetItem {
  date: string,
  rate: number,
}

export interface IDataset {
  id: number,
  data: IDatasetItem[]
}

export interface IProductInfo {
  id: number, //产品id
  name: string, //产品名称
  number: string, //产品代码
  type: number, //产品类型
  saleType: SaleState, //产品售卖状态
  isRedemptionOperation: string,
  redemptionCycle: string, //赎回周期
  annualizedRate: number, //收益率
  annualizedCycle: string, //收益周期
  isPurchaseAmount: string,
  remainingPurchaseAmount: number, //剩余购买额度
  tip: string, //提示
  risk: string, //风险
  title: string, //标题
  minimumPurchaseAmount: number, //最低购买金额
  eachCost: number, //每一份多少钱
  performanceExplanation: string, //业绩说明
  createdTime: string, //产品创建时间
  buyRuleId: number, //购买规则Id
  redemptionRuleId: number, //赎回规则Id
  purchaseProcessId: number, //购买流程ID
  redemptionProcessId: number,
  productHistoricalPerformanceId: number,
  productProfileId: number,
}

export type GetProductTypeListResp = IProductType[]

export type GetProductListResp = IProductItem[]

export type GetHistoricalPerformanceListResp = IHistoricalPerformance[]

