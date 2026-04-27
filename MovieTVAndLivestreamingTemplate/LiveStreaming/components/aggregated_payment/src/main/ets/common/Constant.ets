/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export enum PickerType {
  SHEET = 0,
  DIALOG = 1,
  FULLSCREEN = 2
}

export enum ChannelType {
  HUAWEI_PAY = 0,
  ALI_PAY = 1,
  WECHAT_PAY = 2
}

export interface Channel {
  type: ChannelType,
  name: string,
  selectEvent: (event: ClickEvent) => void;
}

export class WxExtraInfo {
  partnerId: string = ''
  appId: string = ''
  packageValue: string = ''
  prepayId: string = ''
  nonceStr: string = ''
  timeStamp: string = ''
  sign: string = ''
  extData: string = ''
}

export const PAYMENT_CHANNEL: Channel[] = [
  {
    type: ChannelType.HUAWEI_PAY,
    name: '华为支付',
    selectEvent: () => {
    },
  },
  {
    type: ChannelType.ALI_PAY,
    name: '支付宝',
    selectEvent: () => {
    },
  },
  {
    type: ChannelType.WECHAT_PAY,
    name: '微信支付',
    selectEvent: () => {
    },
  }
];