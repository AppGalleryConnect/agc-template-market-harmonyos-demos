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
import { Operation, Setting } from '../../components';
import { generateRandomString } from '../../api';
import { OrderModel, IconButtonProps, SettingProps } from '../../model';
import { signOut, getAuthInfo, init } from '@ohos/agconnect-auth-component';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.Personal')).toString();

@Component
export struct Personal {
  @State fontColor: string = 'rgba(0, 0, 0, 0.4)';
  @State displayPhone: string = '';
  @State displayName: string = '';
  @State uid: string = "";
  @State token: string = "";
  @State orderList: Array<OrderModel> = [];
  @State orderIdList: Array<number> = [];
  @State notPaiedOrderList: Array<OrderModel> = [];
  @State paiedOrderList: Array<OrderModel> = [];
  @Link @Watch('onOrderCountChange') orderCount: { [key: string]: number };
  @Link @Watch("onOrderSnapShotChange") orderSnapShot: IconButtonProps[];
  @State settingSnapShot: SettingProps[] = [
    new SettingProps({
      text: '收货地址',
      click: () => {
        router.push({
          url: "pages/Address",
          params: {
            userId: this.uid,
            token: this.token
          }
        })
      }
    }),
    new SettingProps({
      text: '支付设置',
      click: () => {
      }
    }),
    new SettingProps({
      text: '帐号与安全',
      click: () => {
      }
    })
  ]

  @Styles itemMargin(){
    .margin({ left: $r('app.float.setting_margin_left'), right: $r('app.float.setting_margin_right') })
  }

  async aboutToAppear() {
    init(getContext(this));
    getAuthInfo().then(async (res) => {
      if (res) {
        this.uid = res.getUid();

        await this.getToken(res);
        this.displayPhone = res.getPhone()?.toString();
        Logger.info(domain, TAG, "user has login " + this.uid);
        Logger.info(domain, TAG, "user has login " + this.displayPhone);
      } else {
        Logger.info(domain, TAG, "user has not login");
        router.push({
          url: 'pages/Login'
        })
      }
    }).catch((err) => {
      Logger.info(domain, TAG, "get auth " + err)
    })
  }

  getToken(user) {
    return user.getToken(false).then(token => {
      this.token = token.getString();
    });
  }

  onOrderCountChange() {
    Logger.info(domain, TAG, "order count changed")
  }

  onOrderSnapShotChange() {
    Logger.info(domain, TAG, "order snapshot changed")
  }

  @Builder AuthInfo() {
    Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      Image($r('app.media.men'))
        .width(72)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .margin({ left: $r('app.float.setting_margin_left'), top: $r('app.float.margin_top_middle') })

      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center, direction: FlexDirection.Column }) {
        Text(`用户_${generateRandomString(8)}`)
          .width(Constants.WIDTH_HALF)
          .fontSize($r('app.float.font_small'))
          .fontWeight(FontWeight.Medium)
        Text(`${this.displayPhone}`)
          .width(Constants.WIDTH_HALF)
          .fontSize($r('app.float.font_small'))
          .margin({ top: $r('app.float.margin_top_middle') })
      }
      .margin({ top: $r('app.float.margin_top_large'), left: $r('app.float.setting_margin_left') })
    }.height(Constants.HIGH_OPERATION).margin({ bottom: $r('app.float.margin_bottom_large') })
  }

  build() {
    Column() {
      this.AuthInfo()

      Operation({ uid: this.uid, token: this.token, orderCount: $orderCount, orderSnapShot: $orderSnapShot });

      Column() {
        ForEach(this.settingSnapShot, item => {
          Setting({ setting: item })
          Divider().color('#D3D3D3')
        })

        Row() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text($r('app.string.personal_about')).fontSize($r('app.float.font_large'))
            Text('>').fontSize($r('app.float.font_small')).fontColor(Color.Gray)
          }.height(Constants.SETTINGITEM_HIGH)
          .onClick(() => {
            router.push({
              url: "pages/About"
            })
          })
        }.itemMargin()
      }
      .backgroundColor(Color.White)
      .width(Constants.WIDTH_NEAR_FULL)
      .margin({ top: $r('app.float.margin_top_large'), bottom: $r('app.float.address_margin_bottom') })
      .borderRadius($r('app.float.border_radius_small'))

      Button($r('app.string.personal_signOut'), { type: ButtonType.Normal })
        .width(Constants.WIDTH_NEAR_FULL)
        .fontColor(Color.Black)
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.border_radius_small'))
        .padding($r('app.float.padding_small'))
        .height(Constants.SETTINGITEM_HIGH)
        .onClick(() => {
          signOut().then(() => {
            router.push({
              url: "pages/Main"
            })
          })
        })
    }
    .width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
    .backgroundColor($r('app.color.page_background'))
  }
}