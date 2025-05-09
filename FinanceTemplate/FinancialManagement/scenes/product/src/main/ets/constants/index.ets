import { IBuyRule, IProductInfo } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { IButtonMoney } from '../types'

export interface IDateButton {
  name: string,
  value: number,
}

export const dateButton: IDateButton[] = [
  {
    name: '近1月',
    value: 1,
  },
  {
    name: '近3月',
    value: 2,
  },
  {
    name: '近6月',
    value: 3,
  },
  {
    name: '近1年',
    value: 4,
  },
  {
    name: '成立以来',
    value: 5,
  }
]

export const privacyProduct: string = '欢迎您使用我们的金融理财模板，您的信任对我们很重要，我们将严格遵守法律法规要求的安全保护措施，保护您的个人信息安全可控。'

export const initProductInfoData: IProductInfo = {
  id: 1,
  name: '--',
  number: '--',
  type: 1,
  redemptionCycle: '--',
  annualizedRate: 0.00,
  annualizedCycle: '--',
  saleType: 1,
  tip: '--',
  risk: '--',
  title: '--',
  minimumPurchaseAmount: 1,
  eachCost: 1,
  performanceExplanation: '--',
  isPurchaseAmount: '--',
  isRedemptionOperation: '--',
  remainingPurchaseAmount: 0,
  createdTime: '----/--/--',
  buyRuleId: 1,
  redemptionRuleId: 1,
  purchaseProcessId: 1,
  redemptionProcessId: 1,
  productHistoricalPerformanceId: 1,
  productProfileId: 1,
}

export const buttonMoneyData: IButtonMoney[] = [
  {
    index: 0,
    text: '1万元'
  },
  {
    index: 1,
    text: '5万元'
  },
  {
    index: 2,
    text: '10万元'
  },
  {
    index: 3,
    text: '全部'
  }
]

export const cycleData: string[] = ['每周', '每两周', '每月']

export const dateDataWeek: string[] = ['周一', '周二', '周三', '周四', '周五']

export const dateDataDay: string[] =
  ['1日', '2日', '3日', '4日', '5日', '6日', '7日', '8日', '9日', '10日', '11日', '12日', '13日', '14日', '15日',
    '16日', '17日', '18日', '19日', '20日', '21日', '22日', '23日', '24日', '25日', '26日', '27日', '28日']