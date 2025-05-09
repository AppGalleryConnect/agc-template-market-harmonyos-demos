export interface IPositionRedemptionInfo {
  id: number,
  productName: string,
  productNumber: string,
  share: number,
  submissionTime: string,
  confirmTime: string,
  arrivalTime: string,
  rate: number,
}

export type GetPositionRedemptionInfoResp = IPositionRedemptionInfo