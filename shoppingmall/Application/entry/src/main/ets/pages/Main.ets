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

import router from '@ohos.router';
import Logger from '@ohos.hilog';
import { Home } from './Home';
import { ShoppingCart } from './ShoppingCart';
import { Message } from './Messages';
import { Personal } from './Personal';
import { MenuObj } from '../../constants';
import { ShopCartModel, CountKeys, QuantityKeys, IconButtonProps } from '../../model';
import { Request, RequestType, OrderType, Auth, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.Main')).toString();

@Entry
@Component
struct main {
  @State @Watch("onCurrentIndexChanged") currentIndex: number = 0;
  @State isSearching: boolean = false;
  @State userId: string = '';
  @State token: string = '';
  @State orderCount: { [key: string]: number } = {};
  @State shopCartList: Array<ShopCartModel> = [];
  @State countKeys: CountKeys = {};
  @State quantityKeys: QuantityKeys = {};
  @State checkedNumber: number = 0;
  @State settleMent: number = 0;
  @State @Watch("shopCartUpdate") isShopCartLoading: boolean = true;
  @State orderSnapShot: IconButtonProps[] = [
    new IconButtonProps({
      key: OrderType.Payment,
      icon: $r('app.media.topay'),
      text: '待付款',
      count: 0,
      index: 1
    }),
    new IconButtonProps({
      key: OrderType.Ship,
      icon: $r('app.media.todelivery'),
      text: '待发货',
      count: 0,
      index: 2
    }),
    new IconButtonProps({
      key: OrderType.Receipt,
      icon: $r('app.media.intransfer'),
      text: '待收货',
      count: 0,
      index: 3
    }),
    new IconButtonProps({
      key: OrderType.Evaluation,
      icon: $r('app.media.tocomment'),
      text: '待评价',
      count: 0,
      index: 4
    })
  ]
  controller: TabsController = new TabsController();

  @Builder TabBuilder(index: number) {
    Column() {
      Image(MenuObj[index].imgUrl)
        .width($r('app.float.img_minor'))
        .height($r('app.float.img_minor'))
        .opacity(this.currentIndex === index ? 1 : 0.4)
        .objectFit(ImageFit.Contain)
      Text(MenuObj[index].title)
        .fontColor(this.currentIndex === index ? $r('app.color.tab_selectFont') : $r('app.color.tab_font'))
        .fontSize($r('app.float.font_small'))
        .margin({ top: 2 })
    }.margin({ left: $r('app.float.setting_margin_left') })
  }

  aboutToAppear() {
    if (router.getParams()) {
      this.currentIndex = <number> router.getParams()['index'];
    }
  }

  onBackPress() {
    if (this.currentIndex == 0) {
      this.isSearching = false;
    } else {
      this.OperateByChangeIndexOrBack(0);
    }
    Logger.info(domain, TAG, "press back in main page");
    return true
  }

  onCurrentIndexChanged() {
    Logger.info(domain, TAG, "index changed");
  }

  shopCartUpdate() {
    Logger.info(domain, TAG, "shopCart loading changed " + this.isShopCartLoading);
  }

  OperateByChangeIndexOrBack(index) {
    this.currentIndex = index;
    Logger.info(domain, TAG, "current index is " + this.currentIndex)
  }

  onPageShow() {
    this.queryOrderList();
    this.queryShopCartList();
  }

  getToken(user) {
    return user.getToken(false).then(token => {
      this.token = token.getString();
    });
  }

  async queryShopCartList() {
    Auth.getAuthUser().then(async (res) => {
      if (res == null) {
        Logger.info(domain, TAG, "user has not login");
      } else {
        this.userId = res.getUid();
        await this.getToken(res);

        Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Query, { "uid": this.userId }).then(res => {
          this.shopCartList = res;
          this.shopCartList.sort((a, b) => +b.sc_id - +a.sc_id)
          this.shopCartList.forEach((item) => {
            if (item.selected === 1) {
              this.settleMent += item.quantity * item.price;
              this.checkedNumber++;
            }
            this.quantityKeys[item.sc_id] = item.quantity
          })
          Logger.info(domain, TAG, "obtain shopCartList success " + this.shopCartList.length);
          this.isShopCartLoading = false
        }).catch((err) => {
          Logger.error(domain, TAG, "obtain ShopCartList failed " + JSON.stringify(err));
        })
      }
    })
  }

  async queryOrderList() {
    Auth.getAuthUser().then(async (res) => {
      if (res == null) {
        Logger.info(domain, TAG, "user has not login");
      } else {
        this.userId = res.getUid();
        await this.getToken(res);

        Request.invokeWithToken(Triggers.Order, this.token, RequestType.Query, { "uid": this.userId }).then(res => {
          this.orderCount = {
            [OrderType.Payment]: res.filter(item => item.status === 0).length,
            [OrderType.Ship]: 0,
            [OrderType.Receipt]: res.filter(item => item.status === 1).length,
            [OrderType.Evaluation]: 0
          }
          this.orderSnapShot.forEach(item => {
            item.count = this.orderCount[item.key]
          })
          console.info("obtain orderList success " + this.orderSnapShot.length);
          Logger.info(domain, TAG, "obtain orderList success " + this.orderSnapShot.length);
        }).catch((err) => {
          Logger.error(domain, TAG, "obtain orderList failed " + JSON.stringify(err));
        })
      }
    })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          Home({ isSearching: $isSearching, token: $token }).height(Constants.CONTENT_HIGH)
        }.tabBar(this.TabBuilder(0))

        TabContent() {
          ShoppingCart({
            shopCartList: $shopCartList,
            settleMent: $settleMent,
            checkedNumber: $checkedNumber,
            quantityKeys: $quantityKeys,
            isLoading: $isShopCartLoading
          }).height(Constants.HIGH_FULL);
        }.tabBar(this.TabBuilder(1))

        TabContent() {
          Message().height(Constants.HIGH_FULL);
        }.tabBar(this.TabBuilder(2))

        TabContent() {
          Personal({ orderCount: $orderCount, orderSnapShot: $orderSnapShot }).height(Constants.HIGH_FULL);
        }.tabBar(this.TabBuilder(3))
      }
      .width(Constants.WIDTH_FULL)
      .barHeight(Constants.SETTINGITEM_HIGH)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.OperateByChangeIndexOrBack(index);
      })
    }
  }
}