import { IPositionInfo } from 'network/src/main/ets/types/responseTypes/GetPositionInfoResp';
import { IRedemptionButton } from '../types';

export enum Gender {
  MALE = '1',
  FEMALE = '2',
}

export const redemptionButtonData: IRedemptionButton[] = [
  {
    index: 0,
    text: '1/4'
  },
  {
    index: 1,
    text: '1/3'
  },
  {
    index: 2,
    text: '1/2'
  },
  {
    index: 3,
    text: '全部'
  }
]

export const positionInfoData: IPositionInfo = {
  id: 0,
  productId: 0,
  productName: '--',
  productNumber: '--',
  positionSize: 0,
  positionAmount: 0,
  positionMarket: 0,
  toBeConfirmedAmount: 0,
  positionCostPrice: 0,
  dailyRate: 0,
  netValue: 0,
  payoutDate: '--',
  dailyProfitAndLoss: 0,
  positionProfit: 0,
  allProfitAndLoss: 0,
  dividendDistributionMethod: '--',
  isRedemption: true,
  redemptionTime: 0,
  redemptionSize: 0,
  redemptionApplicationDate: '--',
  redemptionApplicationConfirmDate: '--',
  fundsReceivedDate: '--',
  redemptionTip: '--',
}
