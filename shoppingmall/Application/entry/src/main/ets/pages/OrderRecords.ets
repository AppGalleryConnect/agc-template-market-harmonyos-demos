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

import Logger from '@ohos.hilog';
import router from '@ohos.router';
import { OrderModel } from '../../model';
import { Order, Empty, Loading } from '../../components';
import { Request, RequestType, Triggers } from '../../api';
import { domain, OrderText, Constants } from '../../constants';

const TAG = new String($r('app.string.OrderRecords')).toString();

@Entry
@Component
struct OrderRecords {
  @State @Watch("onOrderListUpdate") orderList: Array<OrderModel> = [];
  @State currentIndex: number = 0;
  @State isOrderListEmpty: boolean = false;
  controller: TabsController = new TabsController();
  private uid: string;
  private token: string;

  onOrderListUpdate() {
    if (this.orderList) {
      this.isOrderListEmpty = true;
    }
  }

  @Builder TabBuilder(index: number) {
    Column() {
      Text(OrderText[index].title)
        .fontColor(this.currentIndex === index ? $r('app.color.tab_selectFont') : $r('app.color.tab_font'))
        .fontSize($r('app.float.font_large'))
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
  }

  @Builder CustomTabContent(list) {
    if (this.isOrderListEmpty) {
      Scroll() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
          if (!list.length) {
            Empty()
          } else {
            ForEach(list, item => {
              Order({ orderData: item, token: this.token })
            })
          }
        }
      }
    } else {
      Loading()
    }
  }

  aboutToAppear() {
    this.currentIndex = <number> router.getParams()['tabIndex'];
    this.uid = router.getParams()['uid'].toString();
    this.token = router.getParams()['token'].toString();

    this.loadOrderData();
  }

  loadOrderData() {
    Request.invokeWithToken(Triggers.Order, this.token, RequestType.Query, { "uid": this.uid }).then(res => {
      this.orderList = res
      Logger.info(domain, TAG, "the length of orderList is " + this.orderList.length);
    }).catch((err) => {
      Logger.error(domain, TAG, "obtain orderList failed " + JSON.stringify(err));
    })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image($r('app.media.back'))
            .width($r('app.float.img_small'))
            .height($r('app.float.img_small'))
            .margin({ left: $r('app.float.margin_left_large') })
            .onClick(() => {
              router.back();
            })
          Text($r('app.string.order_myOrder'))
            .fontSize($r('app.float.title_font'))
            .fontWeight(FontWeight.Medium).margin({ left: $r('app.float.margin_left_middle') })
        }
      }
      .height(Constants.SETTINGITEM_HIGH)

      Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          this.CustomTabContent(this.orderList)
        }.tabBar(this.TabBuilder(0))

        TabContent() {
          this.CustomTabContent(this.orderList.filter(item => item.status === 0))
        }.tabBar(this.TabBuilder(1))

        TabContent() {
          this.CustomTabContent([])
        }.tabBar(this.TabBuilder(2))

        TabContent() {
          this.CustomTabContent(this.orderList.filter(item => item.status === 1))
        }.tabBar(this.TabBuilder(3))

        TabContent() {
          this.CustomTabContent([])
        }.tabBar(this.TabBuilder(4))
      }
      .width(Constants.WIDTH_FULL)
      .barHeight(30)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }.backgroundColor($r('app.color.page_background')).width(Constants.WIDTH_FULL)
  }
}