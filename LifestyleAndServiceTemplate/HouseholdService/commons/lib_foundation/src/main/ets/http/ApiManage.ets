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
import { IGoodCategory, IGoodInfo } from 'module_base';
import { FilterTagAndList, SearchItem, SearchSource, SearchWordItem } from 'search';
import request from './AxiosBase';
import { OrderStatus, QueryGoodListSource, URL_MAP } from '../common/Constant';
import {
  IAppointmentUpdate,
  ILoginWithHuaweiIDRequest,
  IOrderUpdate,
  ISubmitOrderRequest,
  IUpdateCity,
} from '../model/IRequest';
import { BindMobileWithCodeResp, IHomeInfo, IUserInfo, LoginWithHuaweiIDResp, } from '../model/IResponse';
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
 * 绑定手机号
 */
export const bindMobileWithCode = (code: string, config?: AxiosRequestConfig): Promise<BindMobileWithCodeResp> => {
  const url = URL_MAP.BIND_MOBILE_WITH_CODE;
  return request.post(url, code, config);
};

/**
 * 绑定手机号-确认换绑
 */
export const confirmRebindMobileWithSecret = (rebindSecret: string, config?: AxiosRequestConfig) => {
  const url = URL_MAP.CONFIRM_REBIND_MOBILE;
  return request.post(url, rebindSecret, config);
};

/**
 * 手机号解绑
 */
export const unbindMobile = (): Promise<boolean> => {
  const url = URL_MAP.UNBIND_MOBILE;
  return request.post(url);
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

/**
 * 刷新订阅信息
 */
export const updateAppointmentInfo = (data: IAppointmentUpdate, config?: AxiosRequestConfig) => {
  const url = URL_MAP.UPDATE_APPOINTMENT_INFO;
  return request.post(url, data, config);
};

/**
 * 发送验证码
 */
export const sendCode = (data: string): Promise<string> => {
  const url = URL_MAP.SEND_CODE;
  return request.post(url, data);
};

/**
 * 校验验证码
 */
export const verifyCode = (phone: string, code: string): Promise<boolean> => {
  const url = URL_MAP.VERIFY_CODE;
  return request.get(url, { params: { phone, code } });
};

/**
 * 获取历史词条
 */
export const getHistoryList = (): Promise<SearchWordItem[]> => {
  const url = URL_MAP.GET_HISTORY_LIST;
  return request.get(url);
};

/**
 * 获取猜你想搜
 */
export const getGuessList = (isRefresh: boolean): Promise<SearchWordItem[]> => {
  const url = URL_MAP.GET_GUESS_LIKE_LIST;
  return request.get(url, { params: { isRefresh } });
}

/**
 * 获取搜索结果
 */
export const getResultList = (keyWord: string | SearchWordItem | SearchItem,
  searchSource: SearchSource): Promise<FilterTagAndList[]> => {
  const url = URL_MAP.GET_RESULT_LIST;
  return request.get(url, { params: { keyWord, searchSource } });
}

/**
 * 获取搜索联想
 */
export const getSearchSuggestion = (keyWord: string): Promise<[SearchWordItem[], string[]]> => {
  const url = URL_MAP.GET_SUGGESTION_LIST;
  return request.get(url, { params: { keyWord } });
}

/**
 * 清空历史记录
 */
export const deleteHistoryList = (): Promise<SearchWordItem[]> => {
  const url = URL_MAP.DELETE_HISTORY;
  return request.get(url);
}
