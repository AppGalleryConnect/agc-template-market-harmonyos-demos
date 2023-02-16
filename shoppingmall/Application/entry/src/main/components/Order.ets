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
import { OrderModel } from '../model';
import { Constants } from '../constants/Constants';

@Component
export struct Order {
  private orderData;
  private token;

  @Styles button(){
    .borderColor(Color.Red)
    .borderRadius($r('app.float.border_radius_large'))
    .borderWidth(1)
    .width(Constants.BUTTON_WIDTH)
    .height(Constants.BUTTON_HIGH)
    .backgroundColor(Color.White)
    .alignSelf(ItemAlign.End)
  }

  build() {
    Column({ space: 10 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($r('app.string.order_number'))
            .fontSize($r('app.float.font_large'))
            .margin({ left: $r('app.float.margin_left_small') })
            .fontColor(Color.Gray)
          Text(`${this.orderData.order_id}`)
            .fontSize($r('app.float.font_large'))
            .margin({ left: $r('app.float.margin_left_small') })
        }

        if (this.orderData.status === 0) {
          Text($r('app.string.order_buyer_toPay'))
            .fontColor(Color.Red)
            .fontSize($r('app.float.font_large'))
            .margin({ right: $r('app.float.margin_right_small') })
        } else {
          Text($r('app.string.order_seller_toShip'))
            .fontColor(Color.Red)
            .fontSize($r('app.float.font_large'))
            .margin({ right: $r('app.float.margin_right_small') })
        }
      }

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
        Flex({ justifyContent: FlexAlign.Start }) {
          Image(`${this.orderData.pic_url}`)
            .width($r('app.float.img_large'))
            .height($r('app.float.img_large'))
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
            .alignSelf(ItemAlign.Start)

          Flex({ direction: FlexDirection.Column }) {
            Text(`${this.orderData.name}`).fontSize($r('app.float.font_large'))
              .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });

            ForEach(JSON.parse(this.orderData.spu_attrs), ele => {
              Row({ space: 10 }) {
                Text(`${ele.name}`)
                  .fontSize($r('app.float.font_middle'))
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Medium)
                Text(`${ele.value}`).fontSize($r('app.float.font_middle'))
              }.margin({ top: $r('app.float.margin_top_small') })
            })
          }.margin({ left: $r('app.float.margin_left_large') })
        }

        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.Start }) {
          Text(`￥${this.orderData.price.toFixed(2)}`)
            .fontSize($r('app.float.font_large'))
            .textAlign(TextAlign.End)
            .padding({ right: $r('app.float.margin_right_middle') })
            .width(Constants.PRICE_WIDTH)
          Text(`x${this.orderData.spu_num}`)
            .fontSize($r('app.float.font_middle'))
            .textAlign(TextAlign.End)
            .padding({ right: $r('app.float.operation_padding_right') })
            .fontColor(Color.Gray)
        }
      }.height(Constants.HIGH_OPERATION)

      Text(`实付款￥${this.orderData.price * this.orderData.spu_num}`)
        .fontSize($r('app.float.font_middle'))
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.End)
        .margin({ right: $r('app.float.margin_right_small') })

      if (this.orderData.status === 0) {
        Button($r('app.string.personal_payInstant'))
          .fontSize($r('app.float.font_middle'))
          .fontColor(Color.Red)
          .button()
      } else {
        Button($r('app.string.order_confirm_receipt'), { type: ButtonType.Normal })
          .fontSize($r('app.float.font_middle'))
          .fontColor(Color.Red)
          .button()
      }
    }
    .onClick(() => {
      if (this.orderData.status === 0) {
        let orderSnapShot: OrderModel = {
          order_id: this.orderData.order_id,
          uid: this.orderData.uid,
          spu_id: this.orderData.spu_id,
          spu_num: this.orderData.spu_num,
          status: this.orderData.status,
          amount: this.orderData.amount,
          name: this.orderData.name,
          desc: this.orderData.desc,
          pic_url: this.orderData.pic_url,
          create_time: this.orderData.create_time,
          spu_attrs: this.orderData.spu_attrs,
          price: this.orderData.price
        }
        router.push({
          url: 'pages/OrderDetail',
          params: {
            orderData: orderSnapShot
          }
        })
      } else {
        let orderSnapShot: OrderModel = {
          order_id: this.orderData.order_id,
          uid: this.orderData.uid,
          spu_id: this.orderData.spu_id,
          spu_num: this.orderData.spu_num,
          status: this.orderData.status,
          amount: this.orderData.amount,
          name: this.orderData.name,
          desc: this.orderData.desc,
          pic_url: this.orderData.pic_url,
          create_time: this.orderData.create_time,
          spu_attrs: this.orderData.spu_attrs,
          price: this.orderData.price
        }

        router.push({
          url: 'pages/OrderDetail',
          params: {
            orderData: orderSnapShot,
            token: this.token
          }
        })
      }
    })
    .backgroundColor(Color.White)
    .padding($r('app.float.padding_small'))
    .borderRadius($r('app.float.border_radius_small'))
    .margin({ bottom: $r('app.float.margin_bottom_middle') })
  }
}