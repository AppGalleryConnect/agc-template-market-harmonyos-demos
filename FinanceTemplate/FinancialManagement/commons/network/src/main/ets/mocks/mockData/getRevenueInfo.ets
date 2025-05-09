import { BaseResponse } from '../../types/BaseResponse'
import { GetRevenueInfoResp, IRevenueInfo } from '../../types/responseTypes/GetRevenueInfoResp'

const revenueInfo: IRevenueInfo = {
  totalRevenue: 18.54,
  revenueList: [
    {
      date: '2025-03-01',
      revenue: 0
    },
    {
      date: '2025-03-02',
      revenue: 0
    },
    {
      date: '2025-03-03',
      revenue: 1.45
    },
    {
      date: '2025-03-04',
      revenue: 1.35
    },
    {
      date: '2025-03-05',
      revenue: -0.59
    },
    {
      date: '2025-03-06',
      revenue: 2.08
    },
    {
      date: '2025-03-07',
      revenue: -1.59
    }
  ]
}

export const getRevenueInfo: BaseResponse<GetRevenueInfoResp> = {
  code: 0,
  data: revenueInfo
}