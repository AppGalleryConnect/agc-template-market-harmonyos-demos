import { AxiosRequestHeaders } from '@ohos/axios';
import { DnState, OrderListEnum, RequestUrl } from '../constants/Common';
import { AddCarReq, AddDnOrderReq, CommonReq, MyOrderReq } from '../models/RequestModel';
import {
  CouponResp,
  DishesType,
  GetGoodSpecResp,
  GetHelpMsgResp,
  GetHmSystemResp,
  GetMyCarResp,
  GetMyOrderResp,
  GetStoreInfoResp,
  GetTableInfoResp,
  GetTableTitleResp,
  GetUserInfoResp,
  Good,
  MyCouponResp,
  PackageSpec,
} from '../models/ResponseModel';
import AxiosRequest from './AxiosRequest';

/**
 * 通过APPID调用接口获取店铺storeId，再通过接口获取店铺信息
 * @param params
 * @returns
 */
export async function getHmSystem() {
  let params = {
    hmAppid: AppStorage.get('appId') as string,
  } as CommonReq
  return AxiosRequest.get<GetHmSystemResp>({
    url: RequestUrl.GET_HM_SYSTEM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getUserInfo(storeId: string, openId: string, unionId: string) {
  let params = {
    storeId: storeId,
    openId: openId,
    unionId: unionId,
  } as CommonReq
  return AxiosRequest.get<GetUserInfoResp>({
    url: RequestUrl.GET_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export async function getOpenLoginHm(code: string = '') {
  let params = {
    storeId: AppStorage.get('storeId') as string,
    userId: AppStorage.get('userId') as string,
    code: code ?? AppStorage.get('authCode') as string,
  } as CommonReq
  return AxiosRequest.get<GetUserInfoResp>({
    url: RequestUrl.GET_OPEN_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export async function getCloseLoginHm(code: string = '') {
  let params = {
    storeId: AppStorage.get('storeId') as string,
    userId: AppStorage.get('userId') as string,
    code: code ?? AppStorage.get('authCode') as string,
  } as CommonReq
  return AxiosRequest.get<GetUserInfoResp>({
    url: RequestUrl.GET_CLOSE_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getStoreInfo(storeId: string) {
  let params = {
    storeId: storeId,
  } as CommonReq
  return AxiosRequest.get<GetStoreInfoResp>({
    url: RequestUrl.GET_STORE_INFO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getTableTitle(storeId: string) {
  let params = {
    storeId: storeId,
  } as CommonReq
  return AxiosRequest.get<GetTableTitleResp>({
    url: RequestUrl.GET_TABLE_TITLE_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 4、通过桌号id接口获取桌位信息
 * @param tableid
 * @returns
 */
export function getTableInfo(tableId: string) {
  let params = {
    id: tableId,
  } as CommonReq
  return AxiosRequest.get<GetTableInfoResp>({
    url: RequestUrl.GET_ZHUO_HAO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 通过storeId接口获取商品信息
 * @param storeId
 * @returns
 */
export function getDishesList(storeId: string) {
  let params = {
    storeId: storeId,
  } as CommonReq
  return AxiosRequest.get<Array<DishesType>>({
    url: RequestUrl.GET_DISHES_LIST_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 通过storeId接口获取商品信息
 * @param storeId
 * @returns
 */
export function getGoodInfo(goodId: string) {
  let params = {
    goodId: goodId,
  } as CommonReq
  return AxiosRequest.get<Good>({
    url: RequestUrl.GET_GOOD_INFO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 获取单个商品规格信息
 * @param storeId
 * @returns
 */
export function getGoodSpec(goodId: string, combination: PackageSpec[]) {
  let params = {
    goodId: goodId,
    spec: combination.map(item => item.specName).join(','),
    combination: combination,
  } as CommonReq
  return AxiosRequest.get<GetGoodSpecResp>({
    url: RequestUrl.GET_GOOD_SPEC_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 16、规格菜品到购物车
 * @param storeId
 * @returns
 */
export function addCarBySpec(goodId: string, n: GetGoodSpecResp, num: number) {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params: AddCarReq = {
    money: n.money ?? '',
    goodId: goodId,
    storeId: storeId,
    userId: userId,
    num: num + '',
    specType: n.specType ?? '2',
    spec: n.spec ?? '',
    combination: n.combination ?? [], //规格
    boxMoney: n.boxMoney,
  }
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_ADD_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 12、添加菜品到购物车
 * @param good
 * @param num
 * @returns
 */
export function addCar(good: Good, num: number) {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params: AddCarReq = {
    money: good.money,
    goodId: good.id,
    storeId: storeId,
    userId: userId,
    num: num + '',
    specType: '1',
    spec: '',
    combination: [], //规格ID
    boxMoney: good.boxMoney,
  }
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_ADD_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getMyCar() {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    storeId: storeId,
    userId: userId,
  } as CommonReq
  return AxiosRequest.get<GetMyCarResp>({
    url: RequestUrl.GET_MY_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function clearMyCar() {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    userId: userId,
    storeId: storeId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_DEL_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 13、更新已经添加到购物车的菜品数量
 * @param id 购物车ID
 * @param num 购物车数量
 * @returns
 */
export function updateMyCar(id: string, num: number) {
  let params = {
    id,
    num: num + '',
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_UPD_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 13、提交订单
 * @param id 购物车ID
 * @param num 购物车数量
 * @returns
 */
export function addDnOrder(req: AddDnOrderReq) {
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_ADD_DN_ORDER_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params: req,
  })
}

/**
 * 我的订单列表
 * @param dnState
 * @param state
 * @param page
 * @returns
 */
export function getMyOrder(page: number, tab: number) {
  let dnState = ''
  if (tab === OrderListEnum.ALL) {
    dnState = DnState.ALL
  } else if (tab === OrderListEnum.TO_BE_PAID) {
    dnState = DnState.TO_BE_PAID
  } else if (tab === OrderListEnum.COMPLETED) {
    dnState = DnState.COMPLETED
  } else if (tab === OrderListEnum.CANCELED) {
    dnState = DnState.CANCELED
  }
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    storeId: storeId,
    dnState: dnState,
    userId: userId,
    page,
    pagesize: 10,
  } as MyOrderReq
  console.info(`getMyOrder params info: ${JSON.stringify(params)}.`);
  return AxiosRequest.get<Array<GetMyOrderResp>>({
    url: RequestUrl.GET_MY_ORDER_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getOrderInfo(orderId: string) {
  let params = {
    orderId: orderId,
  } as CommonReq
  console.info(`getMyOrder params info: ${JSON.stringify(params)}.`);
  return AxiosRequest.get<GetMyOrderResp>({
    url: RequestUrl.GET_ORDER_INFO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/*
 * 取消订单
 * @param orderId
 * returns
 * */
export function cancelOrder(orderId: string) {
  let params = {
    orderId: orderId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_CANCEL_ORDER_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params
  })
}

/*
 * 帮助信息
 * @param storeId
 * @returns
 * */
export function getHelpMsg() {
  let params = {
    storeId: AppStorage.get('storeId') as string,
  } as CommonReq
  return AxiosRequest.get<Array<GetHelpMsgResp>>({
    url: RequestUrl.GET_HELP_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params
  })
}

/**
 * 通过storeId 、userId接口获取商家优惠券信息，并且判断哪些券可以领取
 * @returns
 */
export function getCoupons() {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    storeId: storeId,
    userId: userId,
  } as CommonReq
  return AxiosRequest.get<Array<CouponResp>>({
    url: RequestUrl.GET_COUPONS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 通过优惠券couponId、userId接口领取优惠券
 * @param couponId
 * @returns
 */
export function getLqCoupons(couponId: string) {
  let userId: string = AppStorage.get('userId') as string
  let params = {
    couponId: couponId,
    userId: userId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_LQ_COUPONS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getMyCoupons() {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    storeId: storeId,
    userId: userId,
  } as CommonReq
  return AxiosRequest.get<Array<MyCouponResp>>({
    url: RequestUrl.GET_MY_COUPONS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getIsNew() {
  let storeId: string = AppStorage.get('storeId') as string
  let userId: string = AppStorage.get('userId') as string
  let params = {
    storeId: storeId,
    userId: userId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_IS_NEW_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function addGoods(orderId: string) {
  let params = {
    orderId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_ADD_GOODS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function deleteOrder(orderId: string) {
  let params = {
    orderId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_DELETE_ORDER_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getHuaweiPayInfo(orderId: string) {
  let params = {
    orderId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_HUAWEI_PAY_INFO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}