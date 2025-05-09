export interface IRevenueItem {
  date: string,
  revenue: number,
}

export interface IRevenueInfo {
  totalRevenue: number,
  revenueList: IRevenueItem[]
}

export type GetRevenueInfoResp = IRevenueInfo