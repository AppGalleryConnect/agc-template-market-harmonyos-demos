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
import { ITemplate } from '../http/Type';


export enum TypeAddressPage {
  NEW = 1,
  EDIT = 2,
}

export interface ParamAddressPage {
  type: TypeAddressPage;
  param?: ITemplate;
}

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;

export enum ShippingMethod {
  PICK_UP_AT_HOME = '上门取件',
  SELF_SENDING = '自寄',
}


export enum PaymentMethod {
  'PAY_NOW' = 1,
  'PAY_ON_DELIVERY' = 2,
}

export enum OrderType {
  ALL = '全部',
  SEND = '寄快递',
  RECEIVE = '收快递',
}