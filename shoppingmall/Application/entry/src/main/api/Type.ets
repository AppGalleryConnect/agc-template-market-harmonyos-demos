/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export enum Triggers {
  Commodity = 'mall-commodity-$latest',
  ShopCart = 'mall-shopcart-$latest',
  Order = 'mall-order-$latest',
  Address = 'mall-address-$latest'
}

export enum RequestType {
  Insert = 'insert',
  Query = 'query',
  Update = 'update',
  Delete = 'delete',
  Search = 'search',
  QueryById = 'queryById',
  DefaultQuery = 'defaultQuery'
}

export enum OrderType {
  Payment = 'payment',
  Ship = 'ship',
  Receipt = 'receipt',
  Evaluation = 'evaluation'
}