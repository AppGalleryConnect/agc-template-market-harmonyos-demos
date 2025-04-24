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
import { CommonUtils, FullOrderInfo, getOrder, payOrder, RouterMap, RouterModule, SystemSceneUtils } from 'utils';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class MyOrderDetailVM {
  @Trace fullOrderInfo: FullOrderInfo = new FullOrderInfo();
  @Trace isRefreshing: boolean = false;
  uiAbilityContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  init() {
    const paramList: FullOrderInfo[] = RouterModule.getNavParam({ url: RouterMap.MY_ORDER_DETAIL });
    if (paramList.length && paramList[paramList.length - 1]) {
      this.fullOrderInfo = paramList[paramList.length - 1];
    }
  }

  payOrder() {
    CommonUtils.showLoading();
    SystemSceneUtils.requestPaymentPromise(true, this.uiAbilityContext).then(() => {
      payOrder(this.fullOrderInfo.orderId).then(() => {
        CommonUtils.hideLoading();
        this.onRefreshing();
      })
    })
  }


  onRefreshing() {
    getOrder(this.fullOrderInfo.orderId).then(async (resp: FullOrderInfo) => {
      this.fullOrderInfo = resp;
      this.isRefreshing = false;
    })
  }

}
