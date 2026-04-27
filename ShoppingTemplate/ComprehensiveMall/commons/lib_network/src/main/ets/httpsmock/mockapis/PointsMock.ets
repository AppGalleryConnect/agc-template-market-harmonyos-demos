import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios'
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter'
import { RequestUrlMap } from '../../constants/RequestUrlMap'
import { UpdateUserPointsReq } from '../../types/RequestTypes'
import { BaseResponse } from '../../types/responses/BaseResponse'
import {
  ProductForPointsResp,
  RedemptionOrder,
  RedemptionOrderDetailResp,
  RedemptionOrderListResp,
  UserPointRedemptionSku,
  UserPoints,
  UserPointsRecordItem,
  UserPointsRecordResp,
  UserPointsResp,
} from '../../types/responses/PointResponse'
import { AddressInfo } from '../../types/OrderTypes'
import {
  MOCK_POINTS_RECORD_LIST,
  MOCK_POINTS_REDEMPTION_LIST,
  MOCK_REDEMPTION_ORDER_LIST,
} from '../mockdata/MockPointsData'

interface RedemptionListParams {
  status?: number
}

interface RedemptionDetailParams {
  orderId: string
}

interface RedemptionDeleteParams {
  orderId: string
}

interface RedeemProductBody {
  product: UserPointRedemptionSku
  addressInfo: AddressInfo
}

interface UpdateAddressBody {
  orderId: string
  name: string
  phone: string
  address: string
}

interface OrderActionBody {
  orderId: string
}

@ObservedV2
class UserPointsModel implements UserPoints {
  @Trace totalPoints: number = 35
  @Trace checkedDays: number = 1
  @Trace latestCheck: number = 0
  @Trace pointsArr: number[] = [5, 10, 15, 20, 25, 30, 40]
}

export class PointsMockApis {
  private _mockList: UserPointsRecordItem[] = MOCK_POINTS_RECORD_LIST
  private userPointModel: UserPointsModel = new UserPointsModel()

  public start(adapter: AxiosMockAdapter) {
    // 获取用户积分信息
    adapter.onGet(RequestUrlMap.USER_POINTS).reply(() => {
      const res: UserPointsResp = {
        code: 0,
        data: {
          checkedDays: this.userPointModel.checkedDays,
          totalPoints: this.userPointModel.totalPoints,
          latestCheck: this.userPointModel.latestCheck,
          pointsArr: this.userPointModel.pointsArr,
        },
      }
      return [HttpStatusCode.Ok, res]
    })

    // 获取用户积分明细
    adapter.onGet(RequestUrlMap.USER_POINTS_DETAIL).reply((config: AxiosRequestConfig) => {
      const date: string = config.params.date
      const list = this._mockList.filter((item: UserPointsRecordItem) => {
        const temp = new Date(item.time)
        const m = temp.getMonth() + 1
        const str = `${temp.getFullYear()}-${m < 10 ? '0' + m : m}`
        return str === date
      })
      const res: UserPointsRecordResp = {
        code: 0,
        list,
        totalPoints: this.userPointModel.totalPoints,
        month: date,
      }
      return [HttpStatusCode.Ok, res]
    })

    // 更新用户积分
    adapter.onPut(RequestUrlMap.USER_POINTS).reply((config: AxiosRequestConfig) => {
      const data: UpdateUserPointsReq = JSON.parse(config.data) as UpdateUserPointsReq
      const model = this.userPointModel
      model.totalPoints = model.totalPoints + data.newPoints
      model.latestCheck = Date.now()
      model.checkedDays++
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: data.type,
        label: data.label,
        points: data.newPoints,
      }
      this._mockList.unshift(newItem)
      const res: BaseResponse = { code: 0 }
      return [HttpStatusCode.Ok, res]
    })

    // 获取积分可兑换的商品列表
    adapter.onGet(RequestUrlMap.USER_POINTS_PRODUCT).reply(() => {
      const res: ProductForPointsResp = {
        code: 0,
        list: MOCK_POINTS_REDEMPTION_LIST,
      }
      return [HttpStatusCode.Ok, res]
    })

    // 积分兑换商品（扣积分，生成订单）
    adapter.onPost(RequestUrlMap.USER_POINTS_REDEMPTION).reply((config: AxiosRequestConfig) => {
      const body: RedeemProductBody = JSON.parse(config.data) as RedeemProductBody
      this.userPointModel.totalPoints = this.userPointModel.totalPoints - body.product.price
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: 1,
        label: '积分兑换: ' + body.product.title,
        points: -body.product.price,
      }
      this._mockList.unshift(newItem)
      const newOrder: RedemptionOrder = {
        orderId: 'redemption_order_' + Date.now(),
        orderTime: Date.now(),
        status: 0,
        product: body.product,
        addressInfo: body.addressInfo,
      }
      MOCK_REDEMPTION_ORDER_LIST.unshift(newOrder)
      const res: BaseResponse = { code: 0 }
      return [HttpStatusCode.Ok, res]
    })

    // 获取兑换订单列表（支持 status 筛选）
    adapter.onGet(RequestUrlMap.USER_REDEMPTION_LIST).reply((config: AxiosRequestConfig) => {
      const params = config.params as RedemptionListParams
      let list: RedemptionOrder[]
      if (params?.status !== undefined) {
        const statusNum = params.status
        list = MOCK_REDEMPTION_ORDER_LIST.filter((o: RedemptionOrder) => o.status === statusNum)
      } else {
        list = MOCK_REDEMPTION_ORDER_LIST.slice()
      }
      const res: RedemptionOrderListResp = { code: 0, list }
      return [HttpStatusCode.Ok, res]
    })

    // 获取兑换订单详情
    adapter.onGet(RequestUrlMap.USER_REDEMPTION_DETAIL).reply((config: AxiosRequestConfig) => {
      const orderId: string = (config.params as RedemptionDetailParams).orderId
      const order = MOCK_REDEMPTION_ORDER_LIST.find((o: RedemptionOrder) => o.orderId === orderId)
      if (!order) {
        const res: BaseResponse = { code: 1, msg: '订单不存在' }
        return [HttpStatusCode.Ok, res]
      }
      const res: RedemptionOrderDetailResp = { code: 0, data: order }
      return [HttpStatusCode.Ok, res]
    })

    // 修改收货地址
    adapter.onPut(RequestUrlMap.USER_REDEMPTION_ADDRESS).reply((config: AxiosRequestConfig) => {
      const body: UpdateAddressBody = JSON.parse(config.data) as UpdateAddressBody
      const order = MOCK_REDEMPTION_ORDER_LIST.find((o: RedemptionOrder) => o.orderId === body.orderId)
      if (order) {
        order.addressInfo = {
          name: body.name,
          cellphone: body.phone,
          address: body.address,
        }
      }
      const res: BaseResponse = { code: 0 }
      return [HttpStatusCode.Ok, res]
    })

    // 催发货（直接返回成功）
    adapter.onPost(RequestUrlMap.USER_REDEMPTION_URGE).reply(() => {
      const res: BaseResponse = { code: 0, msg: 'success' }
      return [HttpStatusCode.Ok, res]
    })

    // 确认收货（status: 1 → 2）
    adapter.onPut(RequestUrlMap.USER_REDEMPTION_CONFIRM).reply((config: AxiosRequestConfig) => {
      const body: OrderActionBody = JSON.parse(config.data) as OrderActionBody
      const order = MOCK_REDEMPTION_ORDER_LIST.find((o: RedemptionOrder) => o.orderId === body.orderId)
      if (order) {
        order.status = 2
      }
      const res: BaseResponse = { code: 0 }
      return [HttpStatusCode.Ok, res]
    })

    // 删除兑换订单
    adapter.onDelete(RequestUrlMap.USER_REDEMPTION_DELETE).reply((config: AxiosRequestConfig) => {
      const orderId: string = (config.params as RedemptionDeleteParams).orderId
      const index = MOCK_REDEMPTION_ORDER_LIST.findIndex((o: RedemptionOrder) => o.orderId === orderId)
      if (index !== -1) {
        MOCK_REDEMPTION_ORDER_LIST.splice(index, 1)
      }
      const res: BaseResponse = { code: 0 }
      return [HttpStatusCode.Ok, res]
    })
  }
}
