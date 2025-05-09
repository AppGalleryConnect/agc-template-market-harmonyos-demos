import { AxiosRequestHeaders } from '@ohos/axios';
import { RequestUrl } from '../constants/Common';
import { AddCarReq, AddDnOrderReq, AddressReq, CommonReq, MyOrderReq } from '../models/RequestModel';
import {
  AddressInfo,
  BaseResponse,
  CouponResp,
  DishesType,
  Good,
  GoodSpecInfo,
  HmSystem,
  MyCar,
  MyCoupon,
  MyOrderInfo,
  PackageSpec,
  StoreInfo,
  UserInfo,
} from '../models/ResponseModel';
import AxiosRequest from './AxiosRequest';
import { AppStorageV2 } from '@kit.ArkUI';
import { AppInfoModel, StoreInfoModel, UserInfoModel } from '../models/StorageModel';
import { getDate } from '../utils/Utils';

/**
 * 通过packageName调用接口获取店铺storeId，再通过接口获取店铺信息
 * @returns
 */
export async function getHmSystem() {
  let appInfo = AppStorageV2.connect(AppInfoModel) as AppInfoModel
  let params = {
    hmAppid: appInfo.packageName,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<HmSystem>>({
    url: RequestUrl.GET_HM_SYSTEM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getUserInfo(packageName: string, openId: string, unionId: string) {
  let params = {
    packageName: packageName,
    openId: openId,
    unionId: unionId,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<UserInfo>>({
    url: RequestUrl.GET_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export async function getOpenLoginHm(code: string = '') {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    code: code ?? AppStorage.get('authCode') as string,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<UserInfo>>({
    url: RequestUrl.GET_OPEN_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export async function getCloseLoginHm(code: string = '') {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    code,
  } as CommonReq
  return AxiosRequest.get<UserInfo>({
    url: RequestUrl.GET_CLOSE_LOGIN_HM_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getStoreList() {
  return AxiosRequest.get<BaseResponse<Array<StoreInfo>>>({
    url: RequestUrl.GET_STORE_LIST_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
  })
}

export function getStoreInfo(storeId: string) {
  let params = {
    storeId: storeId,
  } as CommonReq
  return AxiosRequest.get<StoreInfo>({
    url: RequestUrl.GET_STORE_INFO_URL,
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
 * 通过goodId接口获取商品详情
 * @param goodId
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
 * @param goodId
 * @param combination
 * @returns
 */
export function getGoodSpec(goodId: string, combination: PackageSpec[]) {
  let params = {
    goodId: goodId,
    spec: combination.map(item => item.specName).join(','),
    combination: combination,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<GoodSpecInfo>>({
    url: RequestUrl.GET_GOOD_SPEC_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 16、规格饮品到购物车
 * @param goodId
 * @param n
 * @param num
 * @returns
 */
export function addCarBySpec(goodId: string, n: GoodSpecInfo, num: number) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params: AddCarReq = {
    money: n.money ?? '',
    goodId: goodId,
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    num: num,
    specType: n.specType ?? '2',
    spec: n.spec ?? '',
    combination: n.combination ?? [], //规格
    boxMoney: n.boxMoney,
  }
  return AxiosRequest.get<BaseResponse<string | undefined>>({
    url: RequestUrl.GET_ADD_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getMyCar() {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
  } as CommonReq
  return AxiosRequest.get<MyCar>({
    url: RequestUrl.GET_MY_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function clearMyCar() {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    userId: userInfo.userInfo.id,
    storeId: storeInfo.storeId,
  } as CommonReq
  return AxiosRequest.get<number>({
    url: RequestUrl.GET_DEL_CAR_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 13、更新已经添加到购物车的饮品数量
 * @param id 购物车ID
 * @param num 购物车数量
 * @returns
 */
export function updateMyCar(id: string, num: number) {
  let params = {
    id,
    num: num,
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
 * @param req 订单参数
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
 * @param page
 * @param tab
 * @returns
 */
export function getMyOrder(page: number, tab: number) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    page,
    pagesize: 10,
    orderListType: tab,
    queryDay: getDate(new Date()),
  } as MyOrderReq
  console.info(`getMyOrder params info: ${JSON.stringify(params)}.`);
  return AxiosRequest.get<Array<MyOrderInfo>>({
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
  return AxiosRequest.get<MyOrderInfo>({
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
  return AxiosRequest.get<BaseResponse>({
    url: RequestUrl.GET_CANCEL_ORDER_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

/**
 * 通过storeId 、userId接口获取商家优惠券信息
 * @returns
 */
export function getCoupons() {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
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
export function postLqCoupons(couponId: string) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let params = {
    couponId: couponId,
    userId: userInfo.userInfo.id,
  } as CommonReq
  return AxiosRequest.post<BaseResponse>({
    url: RequestUrl.LQ_COUPONS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getMyCoupons() {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<Array<MyCoupon>>>({
    url: RequestUrl.GET_MY_COUPONS_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function deleteOrder(orderId: string) {
  let params = {
    orderId,
  } as CommonReq
  return AxiosRequest.get<BaseResponse>({
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
  return AxiosRequest.get<BaseResponse>({
    url: RequestUrl.GET_HUAWEI_PAY_INFO_URL,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function modifyUserInfo(name: string, sex: number) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    name,
    sex,
  } as CommonReq
  return AxiosRequest.post<BaseResponse<UserInfo>>({
    url: RequestUrl.MODIFY_USER_INFO,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getUserAddressList() {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
  } as CommonReq
  return AxiosRequest.get<BaseResponse<Array<AddressInfo>>>({
    url: RequestUrl.GET_USER_ADDRESS_LIST,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function deleteUserAddress(id: number) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    id,
  } as CommonReq
  return AxiosRequest.post<BaseResponse>({
    url: RequestUrl.DELETE_USER_ADDRESS,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getUserAddress(id: number) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    id: id,
  } as AddressReq
  return AxiosRequest.get<BaseResponse<AddressInfo>>({
    url: RequestUrl.GET_USER_ADDRESS,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function modifyUserAddress(address: AddressInfo) {
  let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
    userId: userInfo.userInfo.id,
    id: address.id,
    addressPre: address.addressPre,
    addressNum: address.addressNum,
    name: address.name,
    sex: address.sex,
    tel: address.tel,
    tag: address.tag,
    latitude: address.latitude,
    longitude: address.longitude,
  } as AddressReq
  return AxiosRequest.post<BaseResponse>({
    url: RequestUrl.MODIFY_USER_ADDRESS,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}

export function getPrivacyInfo() {
  let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  let params = {
    storeId: storeInfo.storeId,
  } as AddressReq
  return AxiosRequest.post<BaseResponse<string>>({
    url: RequestUrl.GET_PRIVACY_INFO,
    showLoading: true,
    headers: {} as AxiosRequestHeaders,
    params,
  })
}
