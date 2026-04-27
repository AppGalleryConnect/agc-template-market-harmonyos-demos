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

import { CommonUtils, RouterMap, SystemSceneUtils } from 'module_base';
import {
  cancelOrder,
  CurAppInfo,
  FullOrderInfo,
  getOrder,
  OrderStatus,
  OrderToPayParam,
  payOrder,
  refund,
  RouterModule,
} from 'lib_foundation';
import { CountDownVM } from './CountDownVM';
import { MyOrderVM } from './MyOrderVM';

const CANCEL_TIME: number = 1800000;

@ObservedV2
export class MyOrderDetailVM {
  @Trace fullOrderInfo: FullOrderInfo = new FullOrderInfo();
  @Trace isFromOrderCard: boolean = false;
  @Trace isRefreshing: boolean = false;
  @Trace leftTime: string = '00:00:00';
  countDownVM: CountDownVM = CountDownVM.instance;
  orderVM: MyOrderVM = MyOrderVM.instance;

  init() {
    const paramList: OrderToPayParam[] = RouterModule.getNavParam({ url: RouterMap.MY_ORDER_DETAIL });
    if (paramList.length && paramList[paramList.length - 1]) {
      this.fullOrderInfo = paramList[paramList.length - 1].orderInfo;
      this.isFromOrderCard = paramList[paramList.length - 1].isFromOrderCard;
    }
  }

  // todo 开发者可根据实际时间修改待支付倒计时
  getLeftTime = () => {
    let diffTime = this.fullOrderInfo.orderTime + CANCEL_TIME - Date.now();
    this.leftTime = CommonUtils.convertMillisToTime(diffTime);
  }

  payOrder() {
    this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
    CommonUtils.showLoading();
    // todo: 传入false，不走mock
    SystemSceneUtils.requestPaymentPromise(true).then(() => {
      payOrder(this.fullOrderInfo.orderId).then(() => {
        CommonUtils.hideLoading();
        this.onRefreshing();
      })
    })
  }

  cancelOrder() {
    this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
    CommonUtils.showLoading();
    cancelOrder(this.fullOrderInfo.orderId).then(() => {
      CommonUtils.hideLoading();
      this.onRefreshing();
    })
  }

  applyRefund() {
    CommonUtils.showLoading();
    refund(this.fullOrderInfo.orderId).then(() => {
      CommonUtils.hideLoading();
      this.onRefreshing();
    });
  }

  autoCancelOrder() {
    if (this.fullOrderInfo.status === OrderStatus.TO_PAY) {
      this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
      this.countDownVM.startCountdown(this.fullOrderInfo.orderId, this.cancelByTime);
    }
  }

  cancelByTime = () => {
    this.getLeftTime();
    if (this.leftTime <= '00:00:00') {
      cancelOrder(this.fullOrderInfo.orderId).then(() => {
        this.onRefreshing();
        this.orderVM.queryOrderList(false, { showFullLoading: true });
      })
      this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
    }
  }

  onRefreshing() {
    getOrder(this.fullOrderInfo.orderId).then(async (resp: FullOrderInfo) => {
      this.fullOrderInfo = resp;
      this.isRefreshing = false;
    })
  }
}
