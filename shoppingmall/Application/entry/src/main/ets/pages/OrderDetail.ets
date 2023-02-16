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
import prompt from '@ohos.promptAction';
import { AddressModel } from '../../model';
import { Request, RequestType, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.OrderDetail')).toString();

@Entry
@Component
struct orderDetails {
  @State defaultAddr: AddressModel = new AddressModel();
  @State isPaied: boolean = false;
  private orderDetail;
  private token;

  @Styles wrapper(){
    .backgroundColor(Color.White)
    .padding($r('app.float.padding_small'))
    .borderRadius($r('app.float.border_radius_small'))
    .width(Constants.WIDTH_NEAR_FULL)
  }

  aboutToAppear() {
    this.orderDetail = router.getParams()['orderData'];
    this.token = router.getParams()['token'];

    //获取默认的收货地址
    let params = {
      "uid": this.orderDetail.uid
    };

    Request.invokeWithToken(Triggers.Address, this.token, RequestType.DefaultQuery, params).then(res => {
      this.defaultAddr = res[0];
    }).catch((err) => {
      Logger.error(domain, TAG, "obtain defaultAddress failed " + JSON.stringify(err));
    })
  }

  callBack(msg) {
    prompt.showToast({ message: msg })
    setTimeout(() => {
      router.back()
    }, 1000)
  }

  routerToMainPage() {
    router.push({
      url: "pages/Main"
    })
  }

  updateOrderRecords(orderId, amount: number, status: number) {
    let params = {
      "order_id": orderId,
      "amount": amount,
      "status": status
    }

    Request.invokeWithToken(Triggers.Order, this.token, RequestType.Update, params).then(res => {
      Logger.info(domain, TAG, "update order success " + res);
      if (this.isPaied) {
        this.callBack($r('app.string.order_confirm_desc'))
      } else {
        this.callBack($r('app.string.BuySuccess_desc'))
      }
    }).catch((err) => {
      Logger.error(domain, TAG, "update order failed " + JSON.stringify(err));
    })
  }

  @Builder OrderState() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Image(this.orderDetail.status === 0 ? $r('app.media.topay') : $r('app.media.intransfer'))
        .width($r('app.float.img_middle'))
        .height($r('app.float.img_middle'))

      Text(`${this.orderDetail.status === 0 ? "待买家付款" : "卖家已发货"}`)
        .fontSize($r('app.float.title_font'))
        .margin({ left: $r('app.float.margin_left_middle') })
        .fontColor(Color.Red)
    }
    .margin({ bottom: $r('app.float.margin_bottom_middle') })
    .height(Constants.ORDERITEM_HIGH)
    .wrapper()
  }

  @Builder OrderBasicInfo() {
    Column() {
      Row() {
        Text($r('app.string.order_number')).fontSize($r('app.float.font_large')).fontColor(Color.Gray)
        Text(`${this.orderDetail.order_id}`).fontSize($r('app.float.font_large'))
      }.alignSelf(ItemAlign.Start).alignItems(VerticalAlign.Center)

      Flex() {
        Text($r('app.string.order_createTime')).fontSize($r('app.float.font_large')).fontColor(Color.Gray)
        Text(`${this.orderDetail.create_time}`).fontSize($r('app.float.font_large'))
      }.margin({ top: $r('app.float.margin_top_middle') }).alignSelf(ItemAlign.Start)
    }
    .margin({ bottom: $r('app.float.margin_bottom_middle') })
    .height(Constants.ORDERITEM_HIGH)
    .justifyContent(FlexAlign.Center)
    .wrapper()
  }

  @Builder ReceiptInfo() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Row() {
          Text($r('app.string.personal_address_receiver'))
            .fontSize($r('app.float.font_large'))
            .fontColor(Color.Gray)
            .width(Constants.ORDER_TEXT_WIDTH)
            .textAlign(TextAlign.Start)
          Text(`${this.defaultAddr?.name}`).fontSize($r('app.float.font_large')).fontWeight(FontWeight.Medium)
        }

        Text(`${this.defaultAddr?.phone}`)
          .fontSize($r('app.float.font_large'))
          .fontWeight(FontWeight.Medium)
          .margin({ right: $r('app.float.margin_right_small') })
      }

      Row() {
        Text($r('app.string.personal_address'))
          .fontSize($r('app.float.font_large'))
          .fontColor(Color.Gray)
          .width(Constants.ORDER_TEXT_WIDTH)
          .textAlign(TextAlign.Start)
        Text(`${this.defaultAddr?.detail_addr}`)
          .fontSize($r('app.float.font_large'))
          .fontColor(Color.Gray)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(Constants.ORDER_ADDRESS_WIDTH)
      }.alignSelf(ItemAlign.Start).margin({ top: $r('app.float.margin_top_small') })
    }
    .margin({ bottom: $r('app.float.margin_bottom_middle') })
    .height(Constants.ORDERITEM_HIGH)
    .justifyContent(FlexAlign.Center)
    .wrapper()
  }

  @Builder OrderDetail() {
    Flex({ direction: FlexDirection.Column }) {
      Text($r('app.string.order_list'))
        .fontSize($r('app.float.title_font'))
        .width(Constants.WIDTH_FULL)
        .textAlign(TextAlign.Center)
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
        Flex() {
          Image(`${this.orderDetail.pic_url}`)
            .width($r('app.float.img_large'))
            .height($r('app.float.img_large'))
            .objectFit(ImageFit.Contain)
            .alignSelf(ItemAlign.Start)

          Flex({ direction: FlexDirection.Column }) {
            Text(`【${this.orderDetail.name}】${this.orderDetail.desc}`)
              .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize($r('app.float.font_large'))

            ForEach(JSON.parse(this.orderDetail.spu_attrs), ele => {
              Row({ space: 10 }) {
                Text(`${ele.name}:`).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
                Text(`${ele.value}`).fontSize($r('app.float.font_middle')).maxLines(2).textOverflow({
                  overflow: TextOverflow.Ellipsis
                }).textAlign(TextAlign.Start)
              }.margin({ top: $r('app.float.margin_top_small') })
            })
          }
        }

        Flex({ direction: FlexDirection.Column }) {
          Text(`￥${this.orderDetail.price}`)
            .fontSize($r('app.float.font_middle'))
            .textAlign(TextAlign.End)
            .width(Constants.ORDER_TEXT_WIDTH)
            .fontWeight(FontWeight.Medium)
            .margin({
              right: $r('app.float.margin_right_small')
            })
          Text(`x${this.orderDetail.spu_num}`)
            .fontSize($r('app.float.font_small'))
            .margin({
              top: $r('app.float.margin_top_small')
            })
            .textAlign(TextAlign.End)
            .textAlign(TextAlign.End)
            .width(Constants.ORDER_TEXT_WIDTH)
            .margin({ right: $r('app.float.margin_right_small') })
        }
      }.margin({ top: $r('app.float.margin_top_middle') ,right: $r('app.float.margin_right_large') })
    }
    .margin({ bottom: $r('app.float.margin_bottom_middle') })
    .height(Constants.ORDER_DETAIL_HIGH)
    .wrapper()
  }

  @Builder OrderBilling() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
      Row() {
        Text($r('app.string.order_commodityPrice')).fontSize($r('app.float.font_large')).fontColor(Color.Gray)
        Text('￥').fontSize($r('app.float.font_middle'))
        Text(`${this.orderDetail.amount.toFixed(2)}`).fontSize($r('app.float.font_middle'))
      }.alignSelf(ItemAlign.End).margin({ bottom: $r('app.float.margin_bottom_small') })

      Row() {
        Text($r('app.string.order_freight')).fontSize($r('app.float.font_large')).fontColor(Color.Gray)
        Text('￥0.00').fontSize($r('app.float.font_middle'))
      }.alignSelf(ItemAlign.End).margin({ bottom: $r('app.float.margin_bottom_small') })

      Divider().color(Color.Gray).width(Constants.WIDTH_NEAR_FULL).margin({ bottom: $r('app.float.margin_bottom_small') })

      Row() {
        Text($r('app.string.order_actualPay')).fontSize($r('app.float.font_large')).fontColor(Color.Gray)
        Text('￥').fontSize($r('app.float.font_middle'))
        Text(`${this.orderDetail.amount.toFixed(2)}`).fontSize($r('app.float.font_middle'))
      }.alignSelf(ItemAlign.End)
    }
    .height(Constants.ORDERITEM_HIGH)
    .margin({ bottom: $r('app.float.margin_bottom_large') })
    .wrapper()
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width($r('app.float.img_small'))
          .height($r('app.float.img_small'))
          .margin({ left: $r('app.float.margin_left_middle') })
          .onClick(() => {
            router.back();
          })

        Text($r('app.string.order_myOrder'))
          .fontSize($r('app.float.title_font'))
          .fontWeight(FontWeight.Medium).margin({ left: $r('app.float.margin_left_middle') })
      }.height(Constants.SETTINGITEM_HIGH).width(Constants.WIDTH_FULL)

      this.OrderState()

      this.OrderBasicInfo()

      this.ReceiptInfo()

      this.OrderDetail()

      this.OrderBilling()

      Button(`${this.orderDetail.status === 0 ? "确认支付" : "确认收货"}`, { type: ButtonType.Normal })
        .margin({ right: $r('app.float.margin_right_small') })
        .width(Constants.BUTTON_WIDTH)
        .height(Constants.BUTTON_HIGH)
        .borderColor(Color.Red)
        .fontColor(Color.Red)
        .fontSize($r('app.float.font_large'))
        .borderRadius($r('app.float.border_radius_large'))
        .borderWidth(1)
        .backgroundColor(Color.White)
        .onClick(() => {
          //待更新为已支付订单
          if (this.orderDetail.status === 1) {
            this.isPaied = true
          } else {
            Logger.info(domain, TAG, "state of current order is " + this.orderDetail.status)
          }
          this.updateOrderRecords(this.orderDetail.order_id, this.orderDetail.amount, 1);
        })
        .alignSelf(ItemAlign.End)
    }.backgroundColor($r('app.color.page_background')).width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
  }
}