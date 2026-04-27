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

export enum OrderState {
  WaitToPay = 0,
  Paid,
  Cancelled,
  All
}

@ObservedV2
export class OrderInfo {
  @Trace id: string = '1111'
  @Trace orderNo: string = '202310101523232345'
  @Trace orderState: OrderState = OrderState.WaitToPay
  userName: string = '华为用户'
  userIcon: string = ''
  buyNumbers: number = 423
  @Trace content: string = '礼物赠送'
  price: string = '5'
  @Trace isDelete: boolean = false
  //下单时间
  startTime: number = 0

  constructor(id: string, orderState: OrderState, orderNo: string, content: string,
    isDelete: boolean) {
    this.id = id
    this.orderState = orderState
    this.orderNo = orderNo
    this.content = content
    this.isDelete = isDelete
  }
}

// 订单数据
@ObservedV2
export class SampleOrderInfo {
  @Trace orderInfos: OrderInfo[] = [];
}

// 收藏的课程
@ObservedV2
export class SampleCollectInfo {
  @Trace orderInfos: OrderInfo[] = [];
}