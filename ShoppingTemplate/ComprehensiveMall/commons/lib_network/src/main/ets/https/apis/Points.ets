import { RequestUrlMap } from '../../constants/RequestUrlMap'
import { UpdateUserPointsReq } from '../../types/RequestTypes'
import { BaseResponse } from '../../types/responses/BaseResponse'
import {
  ProductForPointsResp,
  RedemptionOrderDetailResp,
  RedemptionOrderListResp,
  UserPointRedemptionSku,
  UserPointsRecordResp,
  UserPointsResp,
} from '../../types/responses/PointResponse'
import { AddressInfo } from '../../types/OrderTypes'
import request from '../Request'

interface RedeemProductReq {
  product: UserPointRedemptionSku
  addressInfo: AddressInfo
}

interface UpdateAddressReq {
  orderId: string
  name: string
  phone: string
  address: string
}

interface OrderActionReq {
  orderId: string
}

class PointsApis {
  // -------- 积分余额 --------

  getUserPoints(): Promise<UserPointsResp> {
    return request.get(RequestUrlMap.USER_POINTS)
  }

  getUserPointsRecord(date: string): Promise<UserPointsRecordResp> {
    return request.get(RequestUrlMap.USER_POINTS_DETAIL, { params: { date } })
  }

  updateUserPoints(data: UpdateUserPointsReq): Promise<BaseResponse> {
    return request.put(RequestUrlMap.USER_POINTS, data)
  }

  // -------- 积分商城 --------

  getProductForPoints(): Promise<ProductForPointsResp> {
    return request.get(RequestUrlMap.USER_POINTS_PRODUCT)
  }

  redeemPointsForProducts(product: UserPointRedemptionSku, addressInfo: AddressInfo): Promise<BaseResponse> {
    const data: RedeemProductReq = { product, addressInfo }
    return request.post(RequestUrlMap.USER_POINTS_REDEMPTION, data)
  }

  // -------- 兑换记录 --------

  getRedemptionList(status?: number): Promise<RedemptionOrderListResp> {
    if (status !== undefined) {
      return request.get(RequestUrlMap.USER_REDEMPTION_LIST, { params: { status } })
    }
    return request.get(RequestUrlMap.USER_REDEMPTION_LIST)
  }

  getRedemptionDetail(orderId: string): Promise<RedemptionOrderDetailResp> {
    return request.get(RequestUrlMap.USER_REDEMPTION_DETAIL, { params: { orderId } })
  }

  updateRedemptionAddress(orderId: string, addressInfo: AddressInfo): Promise<BaseResponse> {
    const data: UpdateAddressReq = {
      orderId,
      name: addressInfo.name,
      phone: addressInfo.cellphone,
      address: addressInfo.address,
    }
    return request.put(RequestUrlMap.USER_REDEMPTION_ADDRESS, data)
  }

  urgeRedemptionShipment(orderId: string): Promise<BaseResponse> {
    const data: OrderActionReq = { orderId }
    return request.post(RequestUrlMap.USER_REDEMPTION_URGE, data)
  }

  confirmRedemptionReceipt(orderId: string): Promise<BaseResponse> {
    const data: OrderActionReq = { orderId }
    return request.put(RequestUrlMap.USER_REDEMPTION_CONFIRM, data)
  }

  deleteRedemptionOrder(orderId: string): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.USER_REDEMPTION_DELETE, { params: { orderId } })
  }
}

const instance = new PointsApis()
export { instance as PointsApis }
