import { InternalAxiosRequestConfig } from '@ohos/axios';
import { CommonUtil } from 'module_base';
import { ExpressStatus, OrderStatus, OrderType, PaymentMethod, ShippingMethod } from '../common/Constant';
import {
  GetOrderListRequest,
  ICouponRequest,
  IPrepayRequest,
  IVipPrepayRequest,
  NormalRequest,
  RemakeRequest,
  UpdateOrderRequest,
} from '../model/IRequest';
import { IOrder, IOrderInfo, IPrepay, IUserInfo } from '../model/IResponse';
import { MockData } from './MockData';

export class MockApi {
  static userLogin() {
    return MockData.USER_INFO
  }

  static getUserInfo(): IUserInfo {
    return MockData.USER_INFO;
  }

  static updateUserInfo(config?: InternalAxiosRequestConfig) {
    const data: IUserInfo = config?.params
    CommonUtil.assign(MockData.USER_INFO, data);
    return true;
  }

  static vipPrepay(config?: InternalAxiosRequestConfig) {
    const data: IVipPrepayRequest = config?.params
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    const resp: IPrepay = {
      id: timestamp,
      orderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return resp
  }

  static getCheckInList() {
    return MockData.CHECK_IN_LIST
  }

  static getCouponList(config?: InternalAxiosRequestConfig) {
    const data: ICouponRequest = config?.params
    if (data.isVip) {
      return MockData.COUPON_LIST.concat(MockData.VIP_COUPON_LIST)
    } else {
      return MockData.COUPON_LIST
    }
  }

  static getCompanyList() {
    return MockData.COMPANY_LIST
  }

  static getGoodsList() {
    return MockData.GOODS_LIST
  }

  static getServicePointList() {
    return MockData.SERVICE_POINT_LIST
  }

  public static getOrderList(config?: InternalAxiosRequestConfig) {
    const data: GetOrderListRequest = config?.params
    const orderList = MockData.ORDER_LIST
    if (data.status && data.status === OrderStatus.DO_ING) {
      const res = orderList.filter((item) => {
        return item.status === OrderStatus.DO_ING
      }).filter((item) => {
        if (data.orderNo) {
          return item.orderNo === data.orderNo
        }
        return true
      })
      return res
    }
    if (data.type && data.type === OrderType.SEND) {
      const res = orderList.filter((item) => {
        return item.type === OrderType.SEND
      }).filter((item) => {
        if (data.orderNo) {
          return item.orderNo === data.orderNo
        }
        return true
      }).filter((item) => {
        if (data.expressStatus && data.expressStatus !== ExpressStatus.ALL) {
          return item.expressStatus === data.expressStatus
        }
        return true
      })
        .filter((item) => {
          return item.status === OrderStatus.SUCCESS
        })
      return res
    }
    if (data.type && data.type === OrderType.RECEIVE) {
      const res = orderList.filter((item) => {
        return item.type === OrderType.RECEIVE
      }).filter((item) => {
        if (data.orderNo) {
          return item.orderNo === data.orderNo
        }
        return true
      })
        .filter((item) => {
          if (data.expressStatus && data.expressStatus !== ExpressStatus.ALL) {
            return item.expressStatus === data.expressStatus
          }
          return true
        })
        .filter((item) => {
          return item.status === OrderStatus.SUCCESS
        })
      return res
    }
    return orderList
  }

  static getEstimatedPrice() {
    return 100
  }

  static prepay(config?: InternalAxiosRequestConfig) {
    const data: IPrepayRequest = config?.params
    const company = MockData.COMPANY_LIST.find((item) => {
      return item.id === data.expressCompanyId
    })
    const timestamp = new Date().getTime();
    const orderNo: string = timestamp.toString();
    const order: IOrder = {
      id: timestamp,
      type: OrderType.SEND,
      status: OrderStatus.SUCCESS,
      expressStatus: ExpressStatus.PICKUP_PENDING,
      companyName: company?.name ?? '',
      orderNo: Date.now() + '',
      remark: '',
      deliveryTime: CommonUtil.formatFullDate(new Date()),
      receiptTime: '',
      price: 0,
      sendAddress: data.sendAddress,
      getAddress: data.getAddress,
      goods: {
        id: data.goodsInfo.id,
        name: data.goodsInfo.name,
        weight: data.goodsInfo.weight,
        volume: data.goodsInfo.volume,
      },
      day: data.day ?? '',
      time: data.time ?? '',
      paymentMethod: data.payMethod ?? PaymentMethod.PAY_NOW,
      shippingMethod: data.shippingMethod,
      mailCode: CommonUtil.rand(1000, 9999),
    }
    MockData.ORDER_LIST.unshift(order)
    const resp: IPrepay = {
      id: timestamp,
      orderNo: orderNo,
      orderStr: '',
      timestamp: orderNo,
    };
    return resp
  }

  static deleteOrder(config?: InternalAxiosRequestConfig) {
    const data: NormalRequest = config?.params
    const index = MockData.ORDER_LIST.findIndex((item) => {
      return item.id === data.id
    })
    MockData.ORDER_LIST.splice(index, 1)
    return undefined
  }

  static getOrderCount() {
    const sendOrderCount: number = MockData.ORDER_LIST.filter((item) => {
      return item.type === OrderType.SEND
    }).filter((item) => {
      return item.status === OrderStatus.SUCCESS
    }).length

    const getOrderCount: number = MockData.ORDER_LIST.filter((item) => {
      return item.type === OrderType.RECEIVE
    }).filter((item) => {
      return item.status === OrderStatus.SUCCESS
    }).length

    const pendingOrderCount: number = MockData.ORDER_LIST.filter((item) => {
      return item.status === OrderStatus.DO_ING
    }).filter((item) => {
      return item.type === OrderType.RECEIVE
    }).length

    return [sendOrderCount, getOrderCount, pendingOrderCount]
  }

  public static updateOrder(config?: InternalAxiosRequestConfig) {
    const data: UpdateOrderRequest = JSON.parse(config?.data ?? '{}') as UpdateOrderRequest
    const index = MockData.ORDER_LIST.findIndex((item) => {
      return item.id === data.id
    })
    if (index !== -1) {
      const order = MockData.ORDER_LIST[index]
      if (data.expressStatus) {
        order.expressStatus = data.expressStatus
      }
      if (data.sendAddress) {
        order.sendAddress = data.sendAddress
      }
      if (data.getAddress) {
        order.getAddress = data.getAddress
      }
      if (data.expressStatus) {
        order.expressStatus = data.expressStatus
      }
      if (data.goodsInfo) {
        order.goods = data.goodsInfo
      }
      if (data.paymentMethod) {
        order.paymentMethod = data.paymentMethod
      }
      if (data.companyId) {
        const company = MockData.COMPANY_LIST.find((item) => {
          return item.id === data.companyId
        })
        if (company) {
          order.companyName = company?.name
        }
      }
      if (data.day) {
        order.day = data.day
      }
      if (data.time) {
        order.time = data.time
      }
      if (data.servicePointId) {
        order.servicePointId = data.servicePointId
      }
      if (data.grid) {
        order.grid = data.grid
      }
      if (data.couponId) {
        order.couponId = data.couponId
      }
    }
    return undefined
  }

  static addRemakeToOrder(config?: InternalAxiosRequestConfig) {
    const data: RemakeRequest = JSON.parse(config?.data ?? '{}') as RemakeRequest
    const index = MockData.ORDER_LIST.findIndex((item) => {
      return item.id === data.id
    })
    if (index !== -1) {
      MockData.ORDER_LIST[index].remark = data.remake
    }
    return undefined
  }

  public static async getOrderInfo(config?: InternalAxiosRequestConfig) {
    const data: NormalRequest = config?.params
    const orderInfo: IOrderInfo = MockData.ORDER_INFO
    const order = MockData.ORDER_LIST.find((item) => {
      return item.id === Number(data.id)
    })
    if (order) {
      orderInfo.id = order.id
      orderInfo.type = order.type
      orderInfo.status = order.status
      orderInfo.expressStatus = order.expressStatus
      orderInfo.price = order.price
      orderInfo.companyName = order.companyName
      orderInfo.orderNo = order.orderNo
      orderInfo.sendAddress = order.sendAddress
      orderInfo.getAddress = order.getAddress
      orderInfo.goods = order.goods
      orderInfo.day = order.day
      orderInfo.time = order.time
      orderInfo.paymentMethod = order.paymentMethod
      orderInfo.servicePointId = order.servicePointId
      orderInfo.grid = order.grid
      orderInfo.couponId = order.couponId
      orderInfo.shippingMethod = order.shippingMethod
      orderInfo.mailCode = order.mailCode
      if (order.sendAddress) {
        orderInfo.sendPosition = order.sendAddress.name
        const address =
          order.sendAddress.province + order.sendAddress.city + order.sendAddress.district + order.sendAddress.street +
          order.sendAddress.detail
        const res = await CommonUtil.getAddressesFromLocationName(address)
        orderInfo.origins = {
          'latitude': res[0].latitude ?? 0,
          'longitude': res[0].longitude ?? 0,
        }
      }
      if (order.getAddress) {
        orderInfo.getPosition = order.getAddress.name
        if (orderInfo.shippingMethod === ShippingMethod.SELF_SENDING &&
          orderInfo.expressStatus === ExpressStatus.ALL) {
          const servicePoint = MockData.SERVICE_POINT_LIST.find((item) => {
            return orderInfo.servicePointId === item.id
          })
          if (servicePoint) {
            orderInfo.destination = servicePoint.position
          }
        } else {
          let address =
            order.getAddress.province + order.getAddress.city + order.getAddress.district + order.getAddress.street +
            order.getAddress.detail
          let res = await CommonUtil.getAddressesFromLocationName(address)
          if (res.length === 0) {
            address =
              order.getAddress.province + order.getAddress.city + order.getAddress.district + order.getAddress.street
            res = await CommonUtil.getAddressesFromLocationName(address)
          }
          orderInfo.destination = {
            'latitude': res[0].latitude ?? 0,
            'longitude': res[0].longitude ?? 0,
          }
        }
      }

      switch (order.expressStatus) {
        case ExpressStatus.PICKUP_PENDING:
          orderInfo.logisticsInfo = MockData.LOGISTICS_INFO.slice(0, 1)
          break
        case ExpressStatus.PICKUP_ENDING:
          orderInfo.logisticsInfo = MockData.LOGISTICS_INFO.slice(0, 2)
          break
        case ExpressStatus.IN_TRANSIT:
          orderInfo.logisticsInfo = MockData.LOGISTICS_INFO.slice(0, 3)
          break
        case ExpressStatus.IN_DELIVERY:
          orderInfo.logisticsInfo = MockData.LOGISTICS_INFO.slice(0, 4)
          break
        case ExpressStatus.SIGNED_FOR:
          orderInfo.logisticsInfo = MockData.LOGISTICS_INFO
          break
        default:
          break
      }
    }

    return orderInfo
  }
}