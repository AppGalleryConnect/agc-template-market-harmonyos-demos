export interface GetCouponsRequest {
  // 关联华为账号ID
  userId: string
  // 优惠券状态
  status?: string
  // 核销单状态
  couponStatus?: string
  // 活动开始时间
  startTime?: string
  // 活动结束时间
  endTime?: string
  // 页码
  page?: number
  // 请求数
  limit?: number
}


