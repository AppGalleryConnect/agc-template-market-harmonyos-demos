import { OrderBasicInfo } from './OrderBasicInfo'

@ObservedV2
export class CommodityOrderInfo implements OrderBasicInfo {
  banner: ResourceStr = ''
  orderNo: string = ''
  orderTime: string = ''
  orderStatus: number = 0
  addressId: number = 0
  couponId: number = 0
  count: number = 0
  productName: string = ''
  disCountPrice: number = 0
  originalPrice: number = 0
  spuName: string = ''
  freight: number = 0
  amount: number = 0
  discount: number = 0
  phone: string = ''
}