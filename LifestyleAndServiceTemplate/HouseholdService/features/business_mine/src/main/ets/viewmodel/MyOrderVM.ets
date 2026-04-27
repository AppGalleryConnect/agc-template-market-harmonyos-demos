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
import { calendarManager } from '@kit.CalendarKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  FullOrderInfo,
  getOrderList,
  HomeBaseInfo,
  IAppointmentUpdate,
  MY_ORDER_LIST,
  OrderDetailList,
  OrderStatus,
  RouterModule,
  updateAppointmentInfo,
} from 'lib_foundation';
import { CommonUtils, RouterMap, SystemSceneUtils } from 'module_base';

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
  @Trace textWidth: number[] = [0, 0, 0, 0];
  static _instance: MyOrderVM;

  static get instance() {
    if (MyOrderVM._instance) {
      return MyOrderVM._instance;
    }
    MyOrderVM._instance = new MyOrderVM();
    return MyOrderVM._instance;
  }

  async init() {
    this.getRouteParam();
    await this.checkCalendar();
    this.queryOrderList(true, {
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

  queryOrderList(showLoading: boolean, param?: IQueryListParam) {
    if (showLoading) {
      if (param?.showFullLoading) {
        this.isLoading = true;
      }

      if (!this.isLoading) {
        this.isRefreshing = true;
      }

      if (param?.showFullLoading) {
        CommonUtils.showLoading();
      }
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

  async checkCalendar() {
    const calendarMgr: calendarManager.CalendarManager | null = await SystemSceneUtils.getCalendarMgr(false);
    if (!calendarMgr) {
      return;
    }
    try {
      const toUseList: FullOrderInfo[] = await getOrderList(OrderStatus.TO_USE);
      const calendar = await calendarMgr.getCalendar();
      // 获取当前到未来一周的日历事件
      const now = new Date().getTime();
      const weekLater = now + 7 * 24 * 60 * 60 * 1000;
      const data: calendarManager.Event[] =
        await calendar.queryEventInstances(now, weekLater, undefined, ['id', 'title', 'startTime', 'endTime']);
      UtilLog.info(`Succeeded in getting event instances, data -> ${JSON.stringify(data)}`);
      const dataIdSet = new Set(data.map(item => item.id));
      // 检查每个订单的 calendarId 是否在日历中存在
      toUseList.forEach(async item => {
        if (item.setSchedule && !dataIdSet.has(item.calendarId)) {
          const appointInfo: IAppointmentUpdate = {
            orderId: item.orderId,
            setSchedule: false,
            setSubscription: item.setSubscription,
            calendarId: undefined,
          }
          await updateAppointmentInfo(appointInfo);
        }
      });
      return;
    } catch (error) {
      UtilLog.error('[OrderVM]', 'fail to get calendar');
      return;
    }
  }
}