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

import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { Logger } from '../common/Logger';
import { CommonConstants } from '../common/Constant';
import { PopViewUtils } from '../common/PopViewUtils';

export class PhoneParams {
  phones: string[] = [];

  constructor(phones: string[]) {
    this.phones = phones;
  }
}

export function callPhone(value: string) {
  try {
    call.makeCall(value, (err: BusinessError) => {
      if (!err) {
        Logger.info('make call success.');
      } else {
        Logger.error('make call fail, err is:' + JSON.stringify(err));
      }
    });
  } catch (e) {
    promptAction.showToast({ message: '此设备不支持打电话' });
  }
}

@Extend(Text)
function textStyle() {
  .fontSize(18)
  .fontColor('#007dff')
  .width(CommonConstants.FULL_PERCENT)
  .height(48)
  .textAlign(TextAlign.Center)
  .backgroundColor($r('app.color.common_card_bg'))
  .borderRadius(8)
}

@Builder
export function DialogCallBuilder(params: PhoneParams) {
  Column({ space: 10 }) {
    ForEach(params.phones, (phone: string) => {
      Text(phone).textStyle().onClick(() => {
        callPhone(phone);
      })
    }, (v: string) => v)
    Text($r('app.string.btn_common_cancel')).textStyle().onClick(() => {
      PopViewUtils.closePopView();
    })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10, bottom: 30 })

}