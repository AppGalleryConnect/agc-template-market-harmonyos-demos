/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AxiosRequestConfig } from '@ohos/axios';
import request from './AxiosBase';
import { OrderStatus, QueryGoodListSource, URL_MAP } from '../common/Constant';
import {
  ILoginWithHuaweiIDRequest,
  IOrderUpdate,
  ISubmitOrderRequest,
  IUpdateCity,
  IQueryAddr,
} from '../model/IRequest';
import {
  IAddrInfo,
  IGoodCategory,
  IGoodInfo,
  IHomeInfo,
  IUserInfo,
  LoginWithHuaweiIDResp,
} from '../model/IResponse';
import { FullOrderInfo } from '../model/ObserveModel';

/**
 * 华为账号登录
 */
export const loginWithHuaweiID =
  (data: ILoginWithHuaweiIDRequest, config?: AxiosRequestConfig): Promise<LoginWithHuaweiIDResp> => {
    const url = URL_MAP.LOGIN_WITH_HUAWEI_ID;
    return request.post(url, data, config);
  };

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
 * 首页聚合信息
 */
export const getHomeInfo = (): Promise<IHomeInfo> => {
  const url = URL_MAP.GET_HOME_INFO;
  return request.get(url);
};

/**
 * 更新城市
 */
export const updateCitySelected = (city: string) => {
  const url = URL_MAP.UPDATE_CITY_SELECTED;
  const data: IUpdateCity = { city };
  return request.post(url, data);
};

/**
 * 更新当前定位城市
 */
export const updateCurrentCity = (city: string) => {
  const url = URL_MAP.UPDATE_CITY_CURRENT;
  const data: IUpdateCity = { city };
  return request.post(url, data);
};

/**
 * 获取所有的分类信息
 */
export const getAllCategoryServices = (): Promise<IGoodCategory[]> => {
  const url = URL_MAP.GET_CATEGORY_INFO;
  return request.get(url);
};

/**
 * 查询商品列表
 */
export const getGoodList = (source: QueryGoodListSource, keyword?: string): Promise<IGoodInfo[]> => {
  const url = URL_MAP.GET_GOOD_LIST;
  return request.get(url, { params: { source, keyword } });
};

/**
 * 获取单个商品
 */
export const getGood = (goodId: string): Promise<IGoodInfo> => {
  const url = URL_MAP.GET_GOOD;
  return request.get(url, { params: { goodId } });
};

/**
 * 查询所有地址
 */
export const getAddressList = (): Promise<IAddrInfo[]> => {
  const url = URL_MAP.GET_ADDR_LIST;
  return request.get(url);
}

/**
 * 查询单个地址
 */
export const getAddress = (addrId: number): Promise<IAddrInfo> => {
  const url = URL_MAP.GET_ADDR;
  return request.get(url, { params: { addrId } });
}

/**
 * 修改地址
 */
export const updateAddress = (data: IAddrInfo) => {
  const url = URL_MAP.UPDATE_ADDR;
  return request.post(url, data);
}

/**
 * 删除地址
 */
export const deleteAddress = (id: number) => {
  const url = URL_MAP.DELETE_ADDR;
  const data: IQueryAddr = { addrId: id };
  return request.post(url, data);
}

/**
 * 新增地址
 */
export const addAddress = (data: IAddrInfo) => {
  const url = URL_MAP.ADD_ADDR;
  return request.post(url, data);
}

/**
 * 查询订单列表
 */
export const getOrderList = (status: OrderStatus): Promise<FullOrderInfo[]> => {
  const url = URL_MAP.GET_ORDER_LIST;
  return request.get(url, { params: { status } });
}

/**
 * 查询单个订单
 */
export const getOrder = (orderId: string): Promise<FullOrderInfo> => {
  const url = URL_MAP.GET_ORDER;
  return request.get(url, { params: { orderId } });
}

/**
 * 预下单
 */
export const preOrder = (data: ISubmitOrderRequest, config?: AxiosRequestConfig): Promise<string> => {
  const url = URL_MAP.PRE_ORDER;
  return request.post(url, data, config);
};

/**
 * 付款
 */
export const payOrder = (orderId: string) => {
  const url = URL_MAP.PAY_ORDER;
  const data: IOrderUpdate = { orderId };
  return request.post(url, data);
};

/**
 * 退款
 */
export const refund = (orderId: string) => {
  const url = URL_MAP.REFUND;
  const data: IOrderUpdate = { orderId };
  return request.post(url, data);
}

/**
 * 取消订单
 */
export const cancelOrder = (orderId: string) => {
  const url = URL_MAP.CANCEL_ORDER;
  const data: IOrderUpdate = { orderId };
  return request.post(url, data);
};
