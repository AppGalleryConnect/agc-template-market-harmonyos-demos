import { IPositionInfo } from '../types/responseTypes/GetPositionInfoResp';
import { IPositionItem } from '../types/responseTypes/GetPositionListResp';
import { IPositionRedemptionInfo } from '../types/responseTypes/GetPositionRedemptionResp';
import {
  IBuyRule,
  IDataset,
  IHistoricalPerformance,
  IProcess,
  IProductInfo,
  IProductItem,
  IProfile,
  IRedemptionRule,
} from '../types/responseTypes/GetProductResp';
import { IInvestmentRecordItem, IRegularInvestmentItem } from '../types/responseTypes/GetRegularInvestmentResp';
import { ITransactionInfo } from '../types/responseTypes/GetTransactionRecordInfoResp';
import { ITransactionItem } from '../types/responseTypes/GetTransactionRecordListResp';
import { IBannerItem, INoticeItem } from '../types/responseTypes/NoticeResp';

export interface ISettingData {
  id: number,
  label: string,
  value: number,
}

export interface IDollarCostAveragingStorage {
  regularInvestmentItem: IRegularInvestmentItem
  investmentRecordList: IInvestmentRecordItem[]
}

export interface ITransactionStorage {
  id: number,
  type: number, //交易类型
  amount: number, //交易金额
  date: string, //购买时间
  productId: number,
  bankCardNumber: string,
}

export enum MockStorageMap {
  USER_INFO = 'mockUserInfo',
  USER_ACCOUNT = 'mockUserAccount',
  PRODUCT_LIST = 'mockProductList',
  VERIFICATION_CODE = 'mockVerificationCode',
  DOLLAR_COST_AVERAGING = 'mockDollarCostAveraging',
  TRANSACTION_LIST = 'mockTransactionList',
}

export const product1: IProductItem = {
  id: 1,
  name: '理财1号',
  number: 'ES5214541',
  type: 1,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.25,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '交易所工作日17:00前买入T+1计算收益',
  risk: '低风险',
  title: '周末有理',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product2: IProductItem = {
  id: 2,
  name: '理财2号',
  number: 'EWS521454',
  type: 2,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.67,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '交易所工作日17:00前买入T+1计算收益',
  risk: '中风险',
  title: '回行有理',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product3: IProductItem = {
  id: 3,
  name: '理财3号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '普通赎回',
  annualizedRate: 3.35,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '稳健运作',
  risk: '中风险',
  title: '日精选',
  minimumPurchaseAmount: 1,
  eachCost: 10,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product4: IProductItem = {
  id: 4,
  name: '理财4号',
  number: 'EWS521454',
  type: 4,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.49,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '稳健运作',
  risk: '高风险',
  title: '周精选',
  minimumPurchaseAmount: 1,
  eachCost: 1000,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product5: IProductItem = {
  id: 5,
  name: '理财5号',
  number: 'EWS521454',
  type: 5,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.08,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '稳健运作',
  risk: '低风险',
  title: '月精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product6: IProductItem = {
  id: 6,
  name: '理财6号',
  number: 'EWS521454',
  type: 1,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.18,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '稳健运作',
  risk: '低风险',
  title: '季精选',
  minimumPurchaseAmount: 1,
  eachCost: 10,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product7: IProductItem = {
  id: 7,
  name: '理财7号',
  number: 'EWS521454',
  type: 2,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.59,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '稳健运作',
  risk: '低风险',
  title: '年精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product8: IProductItem = {
  id: 8,
  name: '理财8号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.46,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '稳健运作',
  risk: '低风险',
  title: '长线精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product9: IProductItem = {
  id: 9,
  name: '理财9号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '普通赎回',
  annualizedRate: 3.07,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '稳健运作',
  risk: '低风险',
  title: '日精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product10: IProductItem = {
  id: 10,
  name: '理财10号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '普通赎回',
  annualizedRate: 3.66,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '稳健运作',
  risk: '低风险',
  title: '日精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product11: IProductItem = {
  id: 11,
  name: '理财11号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '普通赎回',
  annualizedRate: 3.98,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '稳健运作',
  risk: '低风险',
  title: '日精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const product12: IProductItem = {
  id: 12,
  name: '理财12号',
  number: 'EWS521454',
  type: 3,
  redemptionCycle: '普通赎回',
  annualizedRate: 3.23,
  annualizedCycle: '7日年化',
  saleType: 2,
  tip: '稳健运作',
  risk: '低风险',
  title: '日精选',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。'
}

export const productInfo: IProductInfo = {
  id: 1,
  name: '理财13号',
  number: 'ES521454',
  type: 1,
  redemptionCycle: '快赎1万元，普赎T+1到账',
  annualizedRate: 3.62,
  annualizedCycle: '7日年化',
  saleType: 1,
  tip: '交易所工作日17:00前买入T+1计算收益',
  risk: '低风险',
  title: '周末有理',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '业绩比较基准：本产品定位为现金，对产品设定的投资目标，不是预期收益率。管理人基于产品性质、投资策略、过往经验等因素对产品设定的投资目标，不是预期收益率，不代表产品的未来表现和实际收益，不构成对产品收益的承诺，投资需谨慎。',
  isPurchaseAmount: '额度充足',
  isRedemptionOperation: '需赎回操作',
  remainingPurchaseAmount: 234156,
  createdTime: '2024/11/25',
  buyRuleId: 1,
  redemptionRuleId: 1,
  purchaseProcessId: 1,
  redemptionProcessId: 1,
  productHistoricalPerformanceId: 1,
  productProfileId: 1,
}

export const buyRule: IBuyRule = {
  id: 1,
  purchaseRate: 0,
  subscriptionRate: 0,
  minimumPurchaseAmount: 1,
  minimumHoldingShare: 1,
  pricePerShare: 10,
  date: '本产品每日可购买，交易所工作日0:00-15:00购买，T+1交易所工作日确认；15:00后购买，T+2交易所工作日确认'
}

export const redemptionRule: IRedemptionRule = {
  id: 1,
  redemptionRate: 0,
  minimumRedemptionAmount: 1,
  minimumRedemptionShare: 1,
  date: '本产品每日可购买，交易所工作日0:00-15:00购买，T+1交易所工作日确认；15:00后购买，T+2交易所工作日确认'
}

export const purchaseProcess: IProcess = {
  id: 1,
  confirmationDate: '12/31',
  redemptionDate: '随时可赎'
}

export const redemptionProcess: IProcess = {
  id: 1,
  confirmationDate: '12/31',
  redemptionDate: '02/03'
}

export const historicalPerformance: IHistoricalPerformance[] = [
  {
    cycle: '近1月',
    risePrice: 0.10,
    fallingPrice: 0,
    annualized: 2.36,
    date: '2025/01/20-2025/02/20',
  },
  {
    cycle: '近3月',
    risePrice: 0.57,
    fallingPrice: 0,
    annualized: 2.42,
    date: '2025/01/20-2025/02/20',
  },
  {
    cycle: '近6月',
    risePrice: 0.10,
    fallingPrice: 0,
    annualized: 2.72,
    date: '2025/01/20-2025/02/20',
  },
  {
    cycle: '今年来',
    risePrice: 0.57,
    fallingPrice: 0,
    annualized: 2.12,
    date: '2025/01/20-2025/02/20',
  }
]

export const profile: IProfile = {
  type: '固定收益类',
  contract: '',
  information: '',
  managementCompany: 'XX银行有限责任公司',
  number: 'GD7890990002',
  date: '2023/11/20',
}

export const annualizedDataset: IDataset = {
  id: 1,
  data: [
    {
      date: '2024/05/01',
      rate: 2.05
    },
    {
      date: '2024/05/02',
      rate: 2.47
    },
    {
      date: '2024/05/03',
      rate: 2.28
    },
    {
      date: '2024/05/04',
      rate: 2.59
    },
    {
      date: '2024/05/05',
      rate: 2.68
    },
    {
      date: '2024/05/06',
      rate: 2.15
    },
    {
      date: '2024/05/07',
      rate: 2.38
    },
    {
      date: '2024/05/08',
      rate: 2.02
    },
    {
      date: '2024/05/09',
      rate: 1.65
    },
    {
      date: '2024/05/10',
      rate: 2.98
    }
  ]
}

export const revenueDataset: IDataset = {
  id: 1,
  data: [
    {
      date: '2024/05/01',
      rate: 5.05
    },
    {
      date: '2024/05/02',
      rate: 2.47
    },
    {
      date: '2024/05/03',
      rate: 2.28
    },
    {
      date: '2024/05/04',
      rate: 2.59
    },
    {
      date: '2024/05/05',
      rate: 2.68
    },
    {
      date: '2024/05/06',
      rate: 2.15
    },
    {
      date: '2024/05/07',
      rate: 2.38
    },
    {
      date: '2024/05/08',
      rate: 2.02
    },
    {
      date: '2024/05/09',
      rate: 1.65
    },
    {
      date: '2024/05/10',
      rate: 2.98
    }
  ]
}


export const positionItem1: IPositionItem = {
  id: 1,
  transactionType: 1,
  transactionAmount: 1000,
  revenue: 10.05,
  revenueDate: '02.26',
  isRedemption: true,
  redemptionTime: '随时可赎',
  productName: '理财1号',
  productId: 1,
}

export const positionItem2: IPositionItem = {
  id: 2,
  transactionType: 1,
  transactionAmount: 10000,
  revenue: 100.76,
  revenueDate: '02.26',
  isRedemption: true,
  redemptionTime: '每日可赎',
  productName: '理财2号',
  productId: 2,
}

export const positionItem3: IPositionItem = {
  id: 3,
  transactionType: 1,
  transactionAmount: 685,
  revenue: 0.76,
  revenueDate: '02.26',
  isRedemption: true,
  redemptionTime: '每日可赎',
  productName: '理财3号',
  productId: 3,
}

export const positionItem4: IPositionItem = {
  id: 4,
  transactionType: 1,
  transactionAmount: 50000,
  revenue: 1254.76,
  revenueDate: '02.26',
  isRedemption: true,
  redemptionTime: '每日可赎',
  productName: '理财4号',
  productId: 4,
}

export const positionItem5: IPositionItem = {
  id: 5,
  transactionType: 1,
  transactionAmount: 50000,
  revenue: 1254.76,
  revenueDate: '02.26',
  isRedemption: true,
  redemptionTime: '随时可赎',
  productName: '理财5号',
  productId: 5,
}

export const positionInfo: IPositionInfo = {
  id: 1,
  productId: 1,
  productName: '理财xx号',
  productNumber: 'EW110052',
  positionSize: 100,
  positionAmount: 10000,
  positionMarket: 10000,
  toBeConfirmedAmount: 0.00,
  positionCostPrice: 0.1809,
  dailyRate: 0.08,
  netValue: 0.1693,
  payoutDate: '03-10',
  dailyProfitAndLoss: 24.5,
  positionProfit: 604.5,
  allProfitAndLoss: 22.5,
  dividendDistributionMethod: '份额分红',
  isRedemption: true,
  redemptionTime: 1,
  redemptionSize: 100,
  redemptionApplicationDate: '今日17:00前',
  redemptionApplicationConfirmDate: '06.03',
  fundsReceivedDate: '06.03',
  redemptionTip: '12月30日17:00前赎回，12月31日可查看到账及收益。',
}

export const redemption: IPositionRedemptionInfo = {
  id: 1,
  productName: '理财61产品',
  productNumber: 'NJ030101',
  share: 1000,
  submissionTime: '03-0317:00前',
  confirmTime: '03-04',
  arrivalTime: '预计03-0424点前',
  rate: 0,
}

export const banner1: IBannerItem = {
  id: 1,
  img: $r('app.media.banner1')
}

export const banner2: IBannerItem = {
  id: 1,
  img: $r('app.media.banner2')
}

export const banner3: IBannerItem = {
  id: 1,
  img: $r('app.media.banner3')
}

export const notice1: INoticeItem = {
  id: 1,
  name: '专注投研，投资知冷暖',
  img: $r('app.media.banner1'),
  date: '2024.03.29',
}

export const notice2: INoticeItem = {
  id: 2,
  name: '搞不清业绩比较基准和年化收益率？阳光投教一张图告诉你什么是业绩比较基准和年化收益率。',
  img: $r('app.media.banner2'),
  date: '2024.03.29',
}

export const notice3: INoticeItem = {
  id: 3,
  name: '搞不清业绩比较基准和年化收益率？阳光投教一张图告诉你什么是业绩比较基准和年化收益率。',
  img: $r('app.media.banner3'),
  date: '2024.03.29',
}

export const saleType1: ISettingData = {
  id: 1,
  label: '在售',
  value: 1
}

export const saleType2: ISettingData = {
  id: 2,
  label: '预售',
  value: 2
}

export const minimumPurchaseAmount1: ISettingData = {
  id: 1,
  label: '1',
  value: 1
}

export const minimumPurchaseAmount2: ISettingData = {
  id: 2,
  label: '10',
  value: 2
}

export const minimumPurchaseAmount3: ISettingData = {
  id: 3,
  label: '100',
  value: 3
}


export const minimumPurchaseAmount4: ISettingData = {
  id: 4,
  label: '1000',
  value: 4
}


export const minimumPurchaseAmount5: ISettingData = {
  id: 5,
  label: '1万元',
  value: 5
}

export const riskLevel1: ISettingData = {
  id: 1,
  label: '低风险',
  value: 1
}

export const riskLevel2: ISettingData = {
  id: 2,
  label: '中风险',
  value: 2
}

export const riskLevel3: ISettingData = {
  id: 3,
  label: '高风险',
  value: 3
}

export const cycle1: ISettingData = {
  id: 1,
  label: '近1月',
  value: 1
}

export const cycle2: ISettingData = {
  id: 2,
  label: '近3月',
  value: 2
}

export const cycle3: ISettingData = {
  id: 3,
  label: '近6月',
  value: 3
}

export const cycle4: ISettingData = {
  id: 4,
  label: '近1年',
  value: 4
}

export const cycle5: ISettingData = {
  id: 5,
  label: '近3年',
  value: 5
}

export const cycle6: ISettingData = {
  id: 6,
  label: '成立以来',
  value: 6
}

export const arrangement1: ISettingData = {
  id: 1,
  label: '综合排序',
  value: 1
}

export const arrangement2: ISettingData = {
  id: 1,
  label: '收益率优先',
  value: 2
}

export const transactionType1: ISettingData = {
  id: 1,
  label: '全部类型',
  value: 1
}

export const transactionType2: ISettingData = {
  id: 2,
  label: '购买',
  value: 2
}

export const transactionType3: ISettingData = {
  id: 3,
  label: '赎回',
  value: 3
}

export const transactionType4: ISettingData = {
  id: 4,
  label: '到期',
  value: 4
}

export const transactionDate1: ISettingData = {
  id: 1,
  label: '近1月',
  value: 1
}

export const transactionDate2: ISettingData = {
  id: 2,
  label: '近3月',
  value: 2
}

export const transactionDate3: ISettingData = {
  id: 3,
  label: '近6月',
  value: 3
}

export const transactionDate4: ISettingData = {
  id: 4,
  label: '近1年',
  value: 4
}

export const dollarCostAveraging1: IDollarCostAveragingStorage = {
  regularInvestmentItem: {
    id: 1,
    productName: '理财41号',
    productNumber: 'EFA45648',
    state: 1,
    money: 500,
    times: 2,
    date: '2019-08-20',
    amount: 500,
    bankCardNo: '654125985465131'
  },
  investmentRecordList: [
    {
      id: 1,
      date: '2019-09-20',
      money: 500,
      state: 2,
      message: '',
    },
    {
      id: 2,
      date: '2019-10-20',
      money: 500,
      state: 3,
      message: '当前支付账号余额不足',
    }
  ]
}

export const dollarCostAveraging2: IDollarCostAveragingStorage = {
  regularInvestmentItem: {
    id: 2,
    productName: '理财42号',
    productNumber: 'EFA1454848',
    state: 1,
    money: 1000,
    times: 2,
    date: '2019-08-20',
    amount: 2000,
    bankCardNo: '654125985465131'
  },
  investmentRecordList: [
    {
      id: 1,
      date: '2019-09-20',
      money: 1000,
      state: 2,
      message: '',
    },
    {
      id: 2,
      date: '2019-10-20',
      money: 1000,
      state: 2,
      message: '',
    }
  ]
}

export const transactionItem1: ITransactionItem = {
  id: 1,
  type: 2,
  amount: 1020,
  share: 23,
  date: '2025-04-09',
  productName: '理财30号',
  bankCardNo: '6548541256987451145',
}

export const transactionItem2: ITransactionItem = {
  id: 2,
  type: 3,
  amount: 1200,
  share: 12,
  date: '2025-03-09',
  productName: '理财31号',
  bankCardNo: '6548541256987451145',
}

export const transactionItem3: ITransactionItem = {
  id: 3,
  type: 4,
  amount: 9600,
  share: 100,
  date: '2025-02-09',
  productName: '理财32号',
  bankCardNo: '6548541256987451145',
}

export const transactionItem4: ITransactionItem = {
  id: 4,
  type: 2,
  amount: 5700,
  share: 100,
  date: '2025-02-09',
  productName: '理财33号',
  bankCardNo: '6548541256987451145',
}

export const transactionItem5: ITransactionItem = {
  id: 5,
  type: 3,
  amount: 5700,
  share: 100,
  date: '2024-12-09',
  productName: '理财34号',
  bankCardNo: '6548541256987451145',
}

export const transactionItem6: ITransactionItem = {
  id: 6,
  type: 2,
  amount: 5700,
  share: 100,
  date: '2024-06-09',
  productName: '理财35号',
  bankCardNo: '6548541256987451145',
}

export const transactionInfo1: ITransactionInfo = {
  id: 1,
  type: 2,
  state: 1,
  amount: 1020,
  date: '2025-04-09',
  productName: '理财30号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: [
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/03/03',
      status: 0,
    }
  ]
}

export const transactionInfo2: ITransactionInfo = {
  id: 2,
  type: 3,
  state: 1,
  amount: 1200,
  date: '2025-03-09',
  productName: '理财31号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: [
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/02/27',
      status: 0,
    }
  ]
}

export const transactionInfo3: ITransactionInfo = {
  id: 3,
  type: 4,
  state: 4,
  amount: 9600,
  date: '2025-02-09',
  productName: '理财32号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: []
}

export const transactionInfo4: ITransactionInfo = {
  id: 4,
  type: 2,
  state: 2,
  amount: 5700,
  date: '2025-02-09',
  productName: '理财33号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: [
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/03/03',
      status: 0,
    }
  ]
}

export const transactionInfo5: ITransactionInfo = {
  id: 5,
  type: 3,
  state: 1,
  amount: 5700,
  date: '2024-12-09',
  productName: '理财34号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: [
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/02/27',
      status: 0,
    }
  ]
}

export const transactionInfo6: ITransactionInfo = {
  id: 6,
  type: 2,
  state: 3,
  amount: 5700,
  date: '2024-06-09',
  productName: '理财35号',
  productNumber: 'ESAD123',
  bankCardNumber: '6548541256987451145',
  status: [
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/02/27',
      status: 1,
    },
    {
      date: '2023/03/03',
      status: 0,
    }
  ],
  msg: '当前支付账号余额不足'
}