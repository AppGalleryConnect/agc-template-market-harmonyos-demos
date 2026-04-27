import request from './AxiosBase';
import { URL_MAP } from '../common/Constant';
import { ICompany, IGoods, IOrder, IOrderInfo, IPrepay, IServicePoint, IUserInfo } from '../model/IResponse';
import { CheckIn, Coupon } from '../model/ObserveModel';
import {
  GetOrderListRequest,
  ICouponRequest,
  IPrepayRequest,
  IVipPrepayRequest,
  NormalRequest,
  RemakeRequest,
  UpdateOrderRequest
} from '../model/IRequest';

/**
 * 用户登录
 */
export const userLogin = (): Promise<IUserInfo> => {
  const url = URL_MAP.USER_LOGIN;
  return request.get(url);
}

/**
 * 用户登出
 */
export const logout = (): Promise<undefined> => {
  const url = URL_MAP.USER_LOGOUT;
  return request.get(url);
}

/**
 * 读取用户信息
 */
export const getUserInfo = (): Promise<IUserInfo> => {
  const url = URL_MAP.GET_USER_INFO;
  return request.get(url);
};

/**
 * 更新用户信息
 */
export const updateUserInfo = (data: IUserInfo) => {
  const url = URL_MAP.UPDATE_USER_INFO;
  return request.post(url, data);
};

/**
 * 获取签到列表
 */
export const getCheckInList = (): Promise<CheckIn[]> => {
  const url = URL_MAP.CHECK_IN;
  return request.get(url);
}

/**
 * 获取优惠券列表
 */
export const getCouponList = (data: ICouponRequest): Promise<Coupon[]> => {
  const url = URL_MAP.COUPON_LIST;
  return request.get(url, { params: data });
}

/**
 * vip支付
 */
export const vipPrepay = (data: IVipPrepayRequest): Promise<IPrepay> => {
  const url = URL_MAP.VIP_PREPAY;
  return request.get(url, { params: data });
}


/**
 * 获取服务点列表
 */
export const getServicePointList = (): Promise<IServicePoint[]> => {
  const url = URL_MAP.SERVICE_POINT_LIST;
  return request.get(url);
}

/**
 * 获取快递公司列表
 */
export const getCompanyList = (): Promise<ICompany[]> => {
  const url = URL_MAP.COMPANY_LIST;
  return request.get(url);
}

/**
 * 获取预估价格
 */
export const getEstimatedPrice = (): Promise<number> => {
  const url = URL_MAP.ESTIMATED_PRICE;
  return request.get(url);
}

/**
 * 支付
 */
export const prepay = (data: IPrepayRequest): Promise<IPrepay> => {
  const url = URL_MAP.PREPAY;
  return request.get(url, { params: data });
}

/**
 * 获取订单列表
 */
export const getOrderList = (data: GetOrderListRequest): Promise<IOrder[]> => {
  const url = URL_MAP.ORDER_LIST;
  return request.get(url, { params: data });
}

/**
 * 获取订单详情
 */
export const getOrderInfo = (data: NormalRequest): Promise<IOrderInfo> => {
  const url = URL_MAP.ORDER_INFO;
  return request.get(url, { params: data });
}

/**
 * 删除订单
 */
export const deleteOrder = (id: number): Promise<undefined> => {
  const url = URL_MAP.DELETE_ORDER;
  return request.delete(url, { params: { id } });
}

/**
 * 更新订单
 */
export const updateOrder = (data: UpdateOrderRequest): Promise<undefined> => {
  const url = URL_MAP.UPDATE_ORDER;
  return request.post(url, data);
}

/**
 * 获取订单数量
 */
export const getOrderCount = (): Promise<number[]> => {
  const url = URL_MAP.ORDER_COUNT;
  return request.get(url);
}

/**
 * 添加备注
 */
export const addRemakeToOrder = (data: RemakeRequest): Promise<undefined> => {
  const url = URL_MAP.ADD_REMAKE;
  return request.post(url, data);
}

/**
 * 获取物品列表
 */
export const getGoodsList = (): Promise<IGoods[]> => {
  const url = URL_MAP.GOODS_LIST;
  return request.post(url);
}