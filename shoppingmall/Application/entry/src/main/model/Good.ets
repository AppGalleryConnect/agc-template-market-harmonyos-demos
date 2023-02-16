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

export interface AttrModel {
  name: string;
  value: string;
}

export interface GoodListModel {
  spu_id: number;
  name: string;
  desc: string;
  pic_url: string;
  price: number;
  category_id:number;
  detail_pic_url:string;
  attr_list:string;
}

export interface GoodModel {
  spu_id: number;
  name: string;
  desc: string;
  pic_url: string;
  price: number;
  category_id:number;
  detail_pic_url:string;
  attr_list:string;
}