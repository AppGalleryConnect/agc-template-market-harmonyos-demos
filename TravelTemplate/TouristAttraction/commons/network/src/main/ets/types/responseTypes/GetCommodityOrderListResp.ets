export interface CommodityOrderListItem {
  orderNo: string
  orderTime: string
  orderStatus: number
  addressId: string
  couponId: number
  count: number
  productName: string
  disCountPrice: number
  freight: number
  amount: number
  discount: number
  banner: ResourceStr
  phone: string
  originalPrice: number
  spuName: string
}

export class GetCommodityOrderListResp extends Array<CommodityOrderListItem> {}