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
import { AppStorageV2 } from '@kit.ArkUI';
import {
  CommonUtils,
  getOrderList,
  HomeBaseInfo,
  MY_ORDER_LIST,
  OrderDetailList,
  OrderStatus,
  RouterMap,
  RouterModule,
} from 'utils';

export interface IQueryListParam {
  tabIndex?: number;
  showFullLoading?: boolean;
}

@ObservedV2
export class MyOrderVM {
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  @Trace selectedIndex: number = 0;
  @Trace curOrderStatus: OrderStatus = OrderStatus.ALL;
  @Trace allList: OrderDetailList[] = [
    new OrderDetailList(),
    new OrderDetailList(),
    new OrderDetailList(),
    new OrderDetailList(),
  ];
  @Trace isRefreshing: boolean = false;
  @Trace isLoading: boolean = false;
  static _instance: MyOrderVM;

  static get instance() {
    if (MyOrderVM._instance) {
      return MyOrderVM._instance;
    }
    MyOrderVM._instance = new MyOrderVM();
    return MyOrderVM._instance;
  }

  init() {
    this.getRouteParam();
    this.queryOrderList({
      showFullLoading: true,
    });
  }

  getRouteParam() {
    const paramList: number[] = RouterModule.getNavParam({ url: RouterMap.MY_ORDER_LIST });
    if (paramList.length && paramList[paramList.length - 1] !== undefined) {
      const index = paramList[paramList.length - 1];
      this.setSelectedIndex(index);
    }
  }

  queryOrderList(param?: IQueryListParam) {
    if (param?.showFullLoading) {
      this.isLoading = true;
    }

    if (param?.showFullLoading) {
      CommonUtils.showLoading();
    }
    if (param?.tabIndex !== undefined) {
      this.setSelectedIndex(param?.tabIndex);
    }
    getOrderList(this.curOrderStatus).then(async (resp) => {
      this.allList[this.selectedIndex].list = resp;
      this.isLoading = false;
      this.isRefreshing = false;
      if (param?.showFullLoading) {
        CommonUtils.hideLoading();
      }
    });
  }

  setSelectedIndex(index: number) {
    this.selectedIndex = index;
    this.curOrderStatus = MY_ORDER_LIST[this.selectedIndex].status!;
  }
}