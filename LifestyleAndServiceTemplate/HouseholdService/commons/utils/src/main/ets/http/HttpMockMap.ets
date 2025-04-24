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

import { InternalAxiosRequestConfig } from '@ohos/axios';
import { URL_MAP } from '../common/Constant';
import { MockApi } from './MockApi';

/**
 * 映射相应mock接口
 * @param config
 * @returns
 */
export const getMockResponse = (config?: InternalAxiosRequestConfig): Object | undefined => {
  const url = config?.url || '';
  switch (url) {
    case URL_MAP.LOGIN_WITH_HUAWEI_ID:
      return MockApi.loginWithHuaweiID();
    case URL_MAP.GET_USER_INFO:
      return MockApi.getUserInfo();
    case URL_MAP.UPDATE_USER_INFO:
      return MockApi.updateUserInfo(config);
    case URL_MAP.GET_HOME_INFO:
      return MockApi.getHomeInfo();
    case URL_MAP.UPDATE_CITY_SELECTED:
      return MockApi.updateCitySelected(config);
    case URL_MAP.UPDATE_CITY_CURRENT:
      return MockApi.updateCurrentCity(config);
    case URL_MAP.GET_CATEGORY_INFO:
      return MockApi.getAllCategoryServices();
    case URL_MAP.GET_GOOD_LIST:
      return MockApi.getGoodList(config);
    case URL_MAP.GET_GOOD:
      return MockApi.getGood(config);
    case URL_MAP.GET_ADDR:
      return MockApi.getAddress(config);
    case URL_MAP.GET_ADDR_LIST:
      return MockApi.getAddressList();
    case URL_MAP.UPDATE_ADDR:
      return MockApi.updateAddress(config);
    case URL_MAP.DELETE_ADDR:
      return MockApi.deleteAddress(config);
    case URL_MAP.ADD_ADDR:
      return MockApi.addAddress(config);
    case URL_MAP.PRE_ORDER:
      return MockApi.preOrder(config);
    case URL_MAP.PAY_ORDER:
      return MockApi.payOrder(config);
    case URL_MAP.GET_ORDER_LIST:
      return MockApi.getOrderList(config);
    case URL_MAP.GET_ORDER:
      return MockApi.getOrder(config);
    case URL_MAP.REFUND:
      return MockApi.refund(config);
    case URL_MAP.CANCEL_ORDER:
      return MockApi.cancelOrder(config);
    default:
      return '';
  }
}