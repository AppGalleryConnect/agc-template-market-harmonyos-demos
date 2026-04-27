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

import { SearchItem, SearchSource, SearchWordItem } from 'search';
import { OrderStatus, QueryGoodListSource } from '../common/Constant';

export interface ILoginWithHuaweiIDRequest {
  clientId: string;
  code: string;
  idToken: string;
  openId: string;
  unionId: string;
}

export interface ISubmitOrderRequest {
  // 商品id
  goodId: string;

  // 地址名称
  addressName: string;

  // 地址详细
  addressStr: string;

  // 联系人姓名
  contactName: string;

  // 联系电话
  contactPhone: string;

  // 子服务id
  selectServiceId: number;

  // 预约时间
  appointTime: number;

  // 备注信息
  remark: string;

  // 实际付款
  actualPay: number;
}

export interface IQueryOrderList {
  status: OrderStatus;
}

export interface IOrderUpdate {
  orderId: string;
}

export interface IAppointmentUpdate {
  orderId: string;

  // 是否设置日程
  setSchedule: boolean;

  // 是否设置订阅
  setSubscription: boolean;

  // 日程id
  calendarId?: number;
}

export interface IUpdateCity {
  city: string;
}

export interface IQueryGood {
  goodId: string;
}

export interface IQueryGoodList {
  source: QueryGoodListSource;
  keyword: string;
}

export interface IVerifyCode {
  phone: string;
  code: string
}

export interface ISearchResultParams {
  keyWord: string | SearchWordItem | SearchItem;
  searchSource: SearchSource
}

