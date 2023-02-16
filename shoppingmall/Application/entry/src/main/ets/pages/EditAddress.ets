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
import display from '@ohos.display';
import { Request, RequestType, Triggers } from '../../api';
import { domain, Constants } from '../../constants';

const TAG = new String($r('app.string.EditAddress')).toString();

@Entry
@Component
struct EditAddress {
  @State receiver: string = '';
  @State phone: string = '';
  @State area: string = '';
  @State detail: string = '';
  @State isDefaultAddress: boolean = false;
  private controller: TextInputController = new TextInputController();
  private userId: string;
  private token: string;
  private addr_id: string;
  private isEdit: boolean = false;
  private screenHeight: number = 0;

  onPageShow() {
    display.getDefaultDisplay().then(res => {
      this.screenHeight = res.height;
      Logger.info(domain, TAG, "get height success " + this.screenHeight);
    }).catch((e) => {
      Logger.error(domain, TAG, "get height error " + JSON.stringify(e));
    })
  }

  aboutToAppear() {
    this.isEdit = router.getParams()['userId'] == null;
    this.token = router.getParams()['token'].toString();
    if (this.isEdit) {
      //为对象时为更新
      this.addr_id = router.getParams()['addr_id'].toString();
      this.receiver = router.getParams()['receiver'].toString();
      this.phone = router.getParams()['phone'].toString();
      this.area = router.getParams()['area'].toString();
      this.detail = router.getParams()['detail'].toString();
      this.isDefaultAddress = router.getParams()['isDefaultAddress']? true : false;
    } else {
      this.userId = router.getParams()['userId'].toString();
    }
  }

  creteObj() {
    if (this.isEdit) {
      return {
        addr_id: this.isEdit ? this.addr_id : Date.now(),
        name: this.receiver,
        phone: this.phone,
        province: this.area.split('/')[0],
        city: this.area.split('/')[1],
        region: this.area.split('/')[2],
        detail_addr: this.detail,
        isdefault: this.isDefaultAddress ? 1 : 0
      }
    } else {
      return {
        addr_id: this.isEdit ? this.addr_id : Date.now(),
        name: this.receiver,
        uid: this.userId,
        phone: this.phone,
        post_code: "",
        province: this.area.split('/')[0],
        city: this.area.split('/')[1],
        region: this.area.split('/')[2],
        detail_addr: this.detail,
        isdefault: this.isDefaultAddress ? 1 : 0
      }
    }
  }

  save(trigger, operation, params) {
    this.insertOrUpdateAddressRecord(trigger, operation, params);
  }

  insertOrUpdateAddressRecord(trigger, path, params) {
    Request.invokeWithToken(trigger, this.token, path, params).then(res => {
      Logger.info(domain, TAG, "insert addressRecord success" + res);
      prompt.showToast({
        message: $r('app.string.personal_save_success'),
        duration: 1000,
        bottom: this.screenHeight * 0.15
      });
      router.back()
    }).catch((err) => {
      Logger.error(domain, TAG, "insert addressRecord failed " + JSON.stringify(err));
    })
  }

  checkAddrParams() {
    if (!this.receiver.length || !this.phone.length || !(this.area.split('/').length === 3) || !this.detail.length) {
      prompt.showToast({
        message: $r('app.string.personal_invalid_address'),
        duration: 1000,
        bottom: this.screenHeight * 0.15
      });
      return false
    }
    return true
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image($r('app.media.back'))
            .margin({ left: $r('app.float.margin_left_large') })
            .onClick(() => {
              router.back();
            })
            .width($r('app.float.img_small'))
            .width($r('app.float.img_small'))
            .objectFit(ImageFit.Contain)

          Text($r('app.string.personal_address'))
            .fontSize($r('app.float.title_font'))
            .fontWeight(FontWeight.Medium).margin({ left: $r('app.float.margin_left_middle') })
        }
      }
      .height(Constants.SETTINGITEM_HIGH).backgroundColor($r('app.color.page_background'))

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text($r('app.string.personal_address_receiver'))
          .fontWeight(FontWeight.Medium)
          .width(Constants.ADDRESS_TEXT_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .textAlign(TextAlign.Start)
        TextInput({ controller: this.controller, text: this.receiver })
          .margin({ left: $r('app.float.margin_left_small') })
          .borderRadius($r('app.float.border_radius_small'))
          .onChange((value: string) => {
            this.receiver = value;
          })
      }
      .width(Constants.ADDRESS_WIDTH)
      .margin({ bottom: $r('app.float.margin_bottom_middle'), top: $r('app.float.margin_top_middle') })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text($r('app.string.personal_address_phone'))
          .fontWeight(FontWeight.Medium)
          .width(Constants.ADDRESS_TEXT_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .textAlign(TextAlign.Start)
        TextInput({ controller: this.controller, text: this.phone })
          .margin({ left: $r('app.float.margin_left_small') })
          .borderRadius($r('app.float.border_radius_small'))
          .onChange((value: string) => {
            this.phone = value;
          })
      }
      .width(Constants.ADDRESS_WIDTH)
      .margin({ bottom: $r('app.float.margin_bottom_middle'), top: $r('app.float.margin_top_middle') })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text($r('app.string.personal_address_area'))
          .fontWeight(FontWeight.Medium)
          .width(Constants.ADDRESS_TEXT_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .textAlign(TextAlign.Start)
        TextInput({ controller: this.controller, placeholder: '格式要求: 省/市/区', text: this.area }).margin({
          left: $r('app.float.margin_left_small')
        }).borderRadius($r('app.float.border_radius_small'))
          .onChange((value: string) => {
            this.area = value;
          })
      }
      .width(Constants.ADDRESS_WIDTH)
      .margin({ bottom: $r('app.float.margin_bottom_middle'), top: $r('app.float.margin_top_middle') })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text($r('app.string.personal_address_default'))
          .fontWeight(FontWeight.Medium)
          .width(Constants.ADDRESS_TEXT_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .textAlign(TextAlign.Start)
        TextInput({ controller: this.controller, text: this.detail })
          .margin({ left: $r('app.float.margin_left_small') })
          .borderRadius($r('app.float.border_radius_small'))
          .height(Constants.ADDRESS_TEXT_HIGH)
          .onChange((value: string) => {
            this.detail = value;
          })
      }
      .width(Constants.ADDRESS_WIDTH)
      .margin({ bottom: $r('app.float.margin_bottom_middle'), top: $r('app.float.margin_top_middle') })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.personal_address_setDefault'))
          .fontWeight(FontWeight.Medium)
          .width(Constants.DEFAULT_ADDRESS_WIDTH)
          .fontSize($r('app.float.font_middle'))
          .textAlign(TextAlign.Start)
        Toggle({
          type: ToggleType.Switch,
          isOn: this.isDefaultAddress
        }).selectedColor(Color.Orange).onChange((isOn: boolean) => {
          this.isDefaultAddress = isOn
        })
      }.width(Constants.ADDRESS_WIDTH).margin({ bottom: $r('app.float.address_margin_bottom') })

      Button($r('app.string.personal_address_save'), { type: ButtonType.Capsule })
        .backgroundColor(Color.Orange)
        .width(Constants.ADDRESS_WIDTH)
        .margin({ top: $r('app.float.margin_top_large') })
        .onClick(() => {
          if (!this.checkAddrParams()) {
            return
          }

          let trigger = Triggers.Address;
          let operation = this.isEdit ? RequestType.Update : RequestType.Insert;
          let params = this.creteObj();

          this.save(trigger, operation, params);
        })
    }
    .width(Constants.WIDTH_FULL)
  }
}