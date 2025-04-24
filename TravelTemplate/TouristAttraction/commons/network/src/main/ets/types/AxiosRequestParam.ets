export interface CreateCommodityOrderRequest {
  orderNo: string
  banner: ResourceStr
  orderTime: string
  orderStatus: number
  addressId: string
  couponId: number
  count: number
  productName: string
  originalPrice: number
  disCountPrice: number
  freight: number
  amount: number
  spuName: string
  discount: number
}

export interface GetOrderDetailRequest {
  category: number,
  orderNo?: string,
  orderStatus?: number
}

export interface CreateTicketOrderRequest {
  orderNo: string
  orderTime: string
  // 已支付或者未支付
  orderStatus: number
  couponId: number
  count: number
  touristId: string[]
  contactId: string
  productName: string
  productPrice: number
  startTime: string
  endTime: string
}

export interface TouristRequest {
  id: string
  name: string
  phone: string
  cardType: number
  cardNo: string
  isChecked: boolean
}

export interface AddressRequest {
  id: string
  name: string
  phone: string
  district: string
  detail: string
  type: number
}

export interface PrepayResp {
  orderNo: string;
  orderStr: string;
  timestamp: string;
}