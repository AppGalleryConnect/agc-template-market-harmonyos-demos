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

export interface OrderModel {
  order_id: number;
  uid: number;
  spu_id: number;
  spu_num: number;
  status: number;
  order_time?: Date;
  pay_time?: Date;
  amount: number;
  create_time?: Date;
  update_time?: Date;
  name: string;
  desc: string;
  pic_url: string;
  spu_attrs?:string;
  price?:number;
}

export interface InsertOrderModel {
  sc_id: number;
  uid: number;
  spu_id: number;
  quantity: number
}

export interface InstantBuyOrderModel {
  spu_id: number;
  amount: number
}