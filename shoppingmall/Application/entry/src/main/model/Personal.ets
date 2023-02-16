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

export class AddressModel {
  addr_id: number = 0;
  uid: number = 0;
  name: string = '';
  phone: string = '';
  post_code: number = 0;
  province: string = '';
  city: string= '';
  region: string= '';
  detail_addr: string = '' ;
  create_time: Date = null;
  update_time: Date = null ;
  isDefault:  1 | 0 = 0;

  constructor (props?: AddressModel){
    if(!props) return;
    this.addr_id = props.addr_id;
    this.uid = props.uid;
    this.name = props.name;
    this.phone = props.phone;
    this.post_code = props.post_code;
    this.province = props.province;
    this.city = props.city;
    this.region = props.region;
    this.detail_addr = props.detail_addr;
    this.create_time = props.create_time;
    this.update_time = props.update_time;
    this.isDefault = props.isDefault;
  }
}

export class IconButtonProps {
  key:string
  icon: string | Resource
  text: string | Resource
  index: number
  count: number
  constructor(props: IconButtonProps) {
    this.key = props.key || ''
    this.icon = props.icon || ''
    this.text = props.text || ''
    this.index = props.index || 0
    this.count = props.count || 0
  }
}

export class SettingProps {
  text: string | Resource
  click: Function
  constructor(props: SettingProps) {
    this.text = props.text || ''
    this.click = props.click
  }
}