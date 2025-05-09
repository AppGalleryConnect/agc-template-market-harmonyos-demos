export interface IPositionItem {
  id: number,
  transactionType: number, //交易类型
  transactionAmount: number, //交易金额
  revenue?: number, //收益
  revenueDate?: string, //收益时间
  isRedemption?: boolean, //是否可以赎回
  redemptionTime?: string, //赎回时间
  productName: string, //产品名称
  productId:number,
}

export type GetPositionListResp = IPositionItem[]