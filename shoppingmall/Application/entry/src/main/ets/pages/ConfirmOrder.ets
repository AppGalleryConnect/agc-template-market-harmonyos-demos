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
import { Loading } from '../../components';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.ConfirmOrder')).toString();

@Entry
@Component
struct ConfirmOrder {
  @State @Watch("defaultAddrObtained") defaultAddr: AddressModel = new AddressModel();
  @State addressList: Array<AddressModel> = [];
  @State hasDefaultAddress: boolean = false;
  @State isLoading: boolean = true;
  private orderItem;
  private totalAmount;
  private userId;
  private token;
  private sc_list;

  defaultAddrObtained() {
    Logger.error(domain, TAG, "defaultAddr obtained");
  }

  @Styles wrapper(){
    .backgroundColor(Color.White)
    .padding($r('app.float.padding_small'))
    .borderRadius($r('app.float.border_radius_small'))
    .width(Constants.WIDTH_NEAR_FULL)
  }

  @Styles flex(){
    .flexShrink(1)
    .flexGrow(1)
    .flexBasis(1)
  }

  aboutToAppear() {
    this.orderItem = router.getParams()['orderData'];
    this.totalAmount = router.getParams()['settleMent'];
    this.userId = router.getParams()['userId'];
    this.token = router.getParams()['token'];
    this.sc_list = router.getParams()['sc_list'];
    this.hasDefaultAddress = !!router.getParams()['hasDefaultAddress'];
    Logger.error(domain, TAG, "userId obtained is" + this.userId);
  }

  async onPageShow() {
    if (!this.addressList.length) {
      this.loadAddressList();
    }
  }

  async loadAddressList() {
    this.addressList = await Request.invokeWithToken(Triggers.Address, this.token, RequestType.DefaultQuery, {
      "uid": this.userId
    });

    if (this.addressList?.length) {
      Logger.error(domain, TAG, "defaultAddr is   " + this.defaultAddr.name);
      this.defaultAddr = this.addressList[0];
      this.hasDefaultAddress = true;
    } else {
      this.hasDefaultAddress = false;
    }

    this.isLoading = false;
  }

  routerToMainPage() {
    router.push({
      url: "pages/Main"
    })
  }

  insertOrderRecord(records, status) {
    if (!this.addressList.length) {
      prompt.showToast({ message: $r('app.string.personal_address_remind'), duration: 1000, bottom: '850' })
      return;
    }

    let params = []
    records.forEach(item => {
      params.push({
        "order_id": item.order_id,
        "uid": item.uid,
        "spu_id": item.spu_id,
        "spu_num": item.spu_num,
        "status": status,
        "amount": item.amount,
        "spu_attrs": item.spu_attrs
      })
    })
    Logger.error(domain, TAG, "insert params with  " + JSON.stringify(params));

    Request.invokeWithToken(Triggers.Order, this.token, RequestType.Insert, params).then(res => {
      Logger.error(domain, TAG, "insert records success with  " + res);
      prompt.showToast({ message: $r('app.string.order_buy_success') })
      setTimeout(() => {
        this.routerToMainPage()
        this.deleteShopCardRecords()
      }, 1500)
    }).catch((err) => {
      Logger.error(domain, TAG, "insert order record failed " + JSON.stringify(err));
      prompt.showToast({ message: $r('app.string.order_buy_failure') })
      setTimeout(() => {
        this.routerToMainPage()
      }, 1500)
    })
  }

  deleteShopCardRecords() {
    Request.invokeWithToken(Triggers.ShopCart, this.token, RequestType.Delete, { "sc_list": this.sc_list })
      .then(res => {
        Logger.info(domain, TAG, "delete shopCart record " + res)
      })
      .catch((err) => {
        Logger.error(domain, TAG, "delete shopCart record failed " + JSON.stringify(err));
      })
  }

  @Builder Address() {
    if (!this.hasDefaultAddress) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Image($r('app.media.add'))
            .objectFit(ImageFit.Contain)
            .width($r('app.float.img_middle'))
            .height($r('app.float.img_middle'))
          Text($r('app.string.order_add_default'))
            .fontSize($r('app.float.title_font'))
            .margin({ left: $r('app.float.setting_margin_left') })
        }

        Text('>').fontSize(20)
      }.onClick(() => {
        router.push({
          url: "pages/EditAddress",
          params: {
            userId: this.userId,
            token: this.token
          }
        })
      }).wrapper()
    } else {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Start }) {
        Text(`${this.defaultAddr?.detail_addr}`)
          .fontSize($r('app.float.title_font'))
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
        Row({ space: 30 }) {
          Text(`${this.defaultAddr?.name}`).fontSize($r('app.float.font_large'))
          Text(`${this.defaultAddr?.phone}`).fontSize($r('app.float.font_large'))
        }.margin({ top: $r('app.float.margin_top_small') })
      }
      .height('10%')
      .wrapper()
    }
  }

  @Builder OrderList() {
    Scroll() {
      Flex({ direction: FlexDirection.Column }) {
        Text($r('app.string.order_list')).fontSize($r('app.float.title_font')).width('100%').textAlign(TextAlign.Center)
        List() {
          ForEach(this.orderItem, item => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                Image(`${item.pic_url}`)
                  .width($r('app.float.img_large'))
                  .height($r('app.float.img_large'))
                  .aspectRatio(1)
                  .objectFit(ImageFit.Contain)
                  .border({ radius: $r('app.float.border_radius_small') })

                Flex({ direction: FlexDirection.Column }) {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text(`${item.name}+${item.desc}`)
                      .maxLines(2).width("70%").textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontSize($r('app.float.font_large'))

                    Flex({ direction: FlexDirection.Column }) {
                      Text(`${item.price.toFixed(2)}`).fontSize($r('app.float.font_middle')).alignSelf(ItemAlign.End)
                      Text(`x${item.spu_num}`).fontSize($r('app.float.font_middle')).alignSelf(ItemAlign.End)
                    }
                  }

                  ForEach(JSON.parse(item.spu_attrs), ele => {
                    Row({ space: 20 }) {
                      Text(`${ele.name}:`)
                        .fontSize($r('app.float.font_middle'))
                        .fontColor(Color.Gray)
                        .fontWeight(FontWeight.Medium)
                      Text(`${ele.value}`).fontSize($r('app.float.font_middle'))
                    }
                  })
                }.margin({ left: $r('app.float.margin_left_small') })
              }
            }
          })
        }.height('60%')
      }
    }
    .margin({ top: $r('app.float.margin_top_middle') })
    .flex()
    .wrapper()
  }

  @Builder Payment() {
    Flex({ direction: FlexDirection.Column }) {
      Text($r('app.string.order_payment'))
        .fontSize($r('app.float.title_font'))
        .width('100%')
        .textAlign(TextAlign.Center)
      Row() {
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Flex({ alignItems: ItemAlign.Center }) {
            Image($r('app.media.wallet')).width($r('app.float.img_single')).height($r('app.float.img_single'))
            Text($r('app.string.order_huawei_wallet'))
              .fontSize($r('app.float.font_large'))
              .margin({ left: $r('app.float.setting_margin_left') })
          }

          Radio({ value: 'Radio3', group: 'radioGroup' }).checked(true).width(32).height(32)
        }
      }
    }
    .height('12%')
    .margin({ top: $r('app.float.margin_top_middle') })
    .wrapper()
  }

  @Builder Confirm() {
    Row({ space: 16 }) {
      Text(`合计：￥${this.totalAmount}`).fontSize($r('app.float.font_large')).fontColor(Color.Red)
      Button($r('app.string.order_submit')).width(Constants.BUTTON_WIDTH).onClick(() => {
        //插入待发货订单,并从购物车删除
        this.insertOrderRecord(this.orderItem, 1)
        console.info("length of orderItem is " + this.orderItem.length)
      })
    }
    .alignSelf(ItemAlign.End)
    .padding({ bottom: $r('app.float.margin_bottom_middle'), right: $r('app.float.margin_right_small') })
    .height('8%')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width($r('app.float.img_small'))
          .height($r('app.float.img_small'))
          .margin({ left: $r('app.float.margin_left_large') })
          .onClick(() => {
            router.back();
          })

        Text($r('app.string.order_confirm'))
          .fontSize($r('app.float.title_font'))
          .fontWeight(FontWeight.Bold).margin({ left: $r('app.float.margin_left_middle') })
      }.alignSelf(ItemAlign.Start).height('5%')

      if (this.isLoading) {
        Loading().zIndex(1)
      }

      this.Address()
      this.OrderList()
      this.Payment()
      this.Confirm()
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}