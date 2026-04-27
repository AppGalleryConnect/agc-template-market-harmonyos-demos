import { BaseResponse } from './BaseResponse'
import { AddressInfo, LogisticsItem } from '../OrderTypes'

// -------- 迁移自 UserResponse.ets --------

export interface UserPoints {
  totalPoints: number
  checkedDays: number
  latestCheck: number // 时间戳
  pointsArr: number[]
}

export interface UserPointsResp extends BaseResponse {
  data: UserPoints
}

export interface UserPointsRecordItem {
  time: number // 时间戳
  type: number // 0:收入(INCOME)  1:支出(EXPENSE)
  label: string
  points: number
}

export interface UserPointsRecordResp extends BaseResponse {
  totalPoints: number
  month: string // YYYY-MM
  list: UserPointsRecordItem[]
}

export interface UserPointRedemptionSku {
  skuCode: string
  price: number
  title: string
  banner: ResourceStr
  description?: string
}

export interface ProductForPointsResp extends BaseResponse {
  list: UserPointRedemptionSku[]
}

// -------- 新增：兑换记录相关 --------

export interface RedemptionOrder {
  orderId: string                  // 订单编号
  orderTime: number                // 兑换时间（timestamp）
  status: number                   // 0:待发货  1:待收货  2:已完成
  product: UserPointRedemptionSku  // 商品信息
  addressInfo: AddressInfo         // 收货地址（复用 OrderTypes.AddressInfo）
  logisticInfo?: LogisticsItem[]   // 物流节点（待收货时存在）
  expressName?: string             // 快递公司名称
  expressNo?: string               // 快递单号
}

export interface RedemptionOrderListResp extends BaseResponse {
  list: RedemptionOrder[]
}

export interface RedemptionOrderDetailResp extends BaseResponse {
  data: RedemptionOrder
}
