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
import { AddressModel } from '../../model';
import { Request, RequestType, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.Auth')).toString();

@Entry
@Component
struct Address {
  @State addressList: Array<AddressModel> = [];
  @State isRefreshing: boolean = false;
  private userId: string;
  private token: string;

  @Styles image(){
    .width($r('app.float.img_small'))
    .height($r('app.float.img_small'))
  }

  onPageShow() {
    this.userId = router.getParams()['userId'].toString();
    this.token = router.getParams()['token'].toString();
    this.loadAddressList();
  }

  async loadAddressList() {
    this.addressList = await Request.invokeWithToken(Triggers.Address, this.token, RequestType.Query, {
      "uid": this.userId
    });
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Image($r('app.media.back')).margin({ left: $r('app.float.margin_left_large') }).onClick(() => {
              router.back();
            }).image()

            Text($r('app.string.personal_address'))
              .fontSize($r('app.float.title_font'))
              .fontWeight(FontWeight.Medium).margin({ left: $r('app.float.margin_left_middle') })
          }
        }
        .height(Constants.SETTINGITEM_HIGH)

        Refresh({ refreshing: this.isRefreshing, offset: 120, friction: 100 }) {
          Scroll() {
            List({ space: 6 }) {
              ForEach(this.addressList, item => {
                ListItem() {
                  Flex({ direction: FlexDirection.Column }) {
                    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                      Flex({ direction: FlexDirection.Column }) {
                        Row({ space: 16 }) {
                          Text(`${item.name}`).fontSize($r('app.float.font_large')).fontWeight(FontWeight.Bold);
                          Text(`${item.phone}`).fontSize($r('app.float.font_large')).fontWeight(FontWeight.Bold);
                          if (item.isdefault === 1) {
                            Text($r('app.string.personal_address_default'))
                              .fontSize($r('app.float.font_middle'))
                              .border({ width: 1, color: Color.Orange, radius: 6 })
                              .padding($r('app.float.padding_small'))
                              .fontColor(Color.Orange)
                          }
                        }.margin({ top: $r('app.float.margin_top_small') })

                        Row() {
                          Text(`${item.province} ${item.city} ${item.region} ${item.detail_addr}`)
                            .fontSize($r('app.float.font_middle'))
                            .maxLines(2);
                        }.margin({ top: $r('app.float.margin_top_small') })
                      }.padding({ left: $r('app.float.address_padding_left') }).width('70%')

                      Image($r('app.media.edit'))
                        .aspectRatio(1)
                        .objectFit(ImageFit.Contain)
                        .margin({ right: $r('app.float.margin_right_middle') })
                        .onClick(() => {
                          router.push({
                            url: 'pages/EditAddress',
                            params: {
                              addr_id: item.addr_id,
                              receiver: item.name,
                              phone: item.phone,
                              area: item.province + '/' + item.city + '/' + item.region,
                              detail: item.detail_addr,
                              isDefaultAddress: item.isdefault,
                              token: this.token
                            }
                          })
                        })
                        .image()
                    }
                  }
                }.height(Constants.HIGH_OPERATION)

              }, item => item.addr_id.toString())
            }
          }
          .backgroundColor(Color.White)
          .borderRadius($r('app.float.border_radius_small'))
          .padding($r('app.float.padding_small'))
          .width(Constants.WIDTH_FULL)
        }.onStateChange((refreshStatus: RefreshStatus) => {
          Logger.info(domain, TAG, 'Refresh onStatueChange state is ' + refreshStatus)
        })
        .onRefreshing(() => {
          this.loadAddressList();
        }).height(Constants.ADDRESS_HIGH)

        Button($r('app.string.personal_address_add'), { type: ButtonType.Capsule })
          .fontColor(Color.White)
          .width(Constants.WIDTH_NEAR_FULL)
          .height(Constants.BUTTON_HIGH)
          .backgroundColor(Color.Orange)
          .margin({ bottom: $r('app.float.margin_bottom_large') })
          .onClick(() => {
            router.push({
              url: 'pages/EditAddress',
              params: {
                userId: this.userId,
                token: this.token
              }
            })
          })
      }
    }
    .width(Constants.WIDTH_FULL)
    .backgroundColor($r('app.color.page_background'))
  }
}