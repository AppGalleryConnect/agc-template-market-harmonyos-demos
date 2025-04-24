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

import { AddressInfo, CommonConstants, FormItem, FormType, RouterMap, RouterModule } from 'utils'
import { ParamAddressPage } from '../common/Constant';
import { AddressVM } from '../viewmodel/AddressVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function EditAddressBuilder() {
  EditAddress()
}

@ComponentV2
export struct EditAddress {
  addrVM: AddressVM = AddressVM.instance;
  @Local address: AddressInfo = new AddressInfo();

  aboutToAppear(): void {
    const params: ParamAddressPage[] = RouterModule.getNavParam({ url: RouterMap.EDIT_ADDRESS });
    if (params.length && params[params.length - 1]) {
      const param = params[params.length - 1];
      this.addrVM.type = param.type;
      if (param.param) {
        this.address = this.addrVM.getObservedAddrInfo(param.param);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          this.FormCard()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        this.BottomBar()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('添加地址', { paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  FormCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.ADDRESS,
          label: '所在地区',
          required: true,
        },
        value: this.address.name!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '详细地址与门牌号',
          required: true,
        },
        value: this.address.address!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '收货人姓名',
          required: true,
        },
        value: this.address.contactName!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          inputType: InputType.PhoneNumber,
          label: '手机号',
          required: true,
          last: true,
        },
        value: this.address.contactPhone!!,
      })
    }
    .margin({ top: 10 })
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  BottomBar() {
    Row() {
      Button('保存地址')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(500)
        .width(CommonConstants.FULL_PERCENT)
        .height(40)
        .onClick(() => {
          this.addrVM.onSubmit(this.address);
        })
    }
    .padding(10)
  }
}
