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

export type SelectKeys = { [key: string]: string }
export type CountKeys = { [key:string]: boolean }
export type QuantityKeys = { [key:string]: number }
type KV = {key: string; value: string, image?: string}
export type Specification = {
  id: string;
  title: string;
  data: KV[]
}

export interface ShopCartModel {
  sc_id: number;
  spu_id: number;
  spu_attrs: string;
  uid: number;
  quantity: number;
  add_time: Date;
  name: string;
  desc: string;
  pic_url: string;
  price: number;
  selected: number;
  update_time: Date;
  isCountOn:boolean;
}

export interface SettleMentModel {
  spu_id: number,
  price: number,
  quantity: number
}