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

import {
  CommonConstants,
  CommonUtils,
  FormItem,
  RouterMap,
  RouterModule,
  FullOrderInfo,
  FormType,
  UIOrderPart,
} from 'utils'
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function SuccessPayBuilder() {
  SuccessPay()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .padding(10)
  .borderRadius(8)
  .backgroundColor(Color.White)
}

@ComponentV2
export struct SuccessPay {
  @Local orderInfo: FullOrderInfo = new FullOrderInfo();

  aboutToAppear(): void {
    const paramList: FullOrderInfo[] = RouterModule.getNavParam({ url: RouterMap.SUCCESS_PAY });
    if (paramList.length && paramList[paramList.length - 1]) {
      this.orderInfo = paramList[paramList.length - 1];
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row({ space: 10 }) {
            Image($r('app.media.ic_public_success')).width(26).height(26)
            Text('支付完成').fontSize(18)
          }.padding({ top: 24, bottom: 30 })

          Column({ space: 16 }) {
            this.FormCard1()
            this.FormCard2()
            this.FormCard3()
          }
        }.width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding(10)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('支付完成', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
    .onBackPressed(() => {
      RouterModule.popToName(RouterMap.MAIN);
      return true;
    })
  }

  @Builder
  FormCard1() {
    Column() {
      FormItem({
        param: {
          type: FormType.TEXT,
          label: '预约地址',
        },
        value: this.orderInfo.addressName,
      })

      FormItem({
        param: {
          type: FormType.TEXT,
          label: '上门时间',
          last: true,
        },
        value: CommonUtils.formatDateTime(this.orderInfo.appointTime),
      })
    }
    .cardContainer()
  }

  @Builder
  FormCard2() {
    Column({ space: 4 }) {
      UIOrderPart({ simpleOrderInfo: this.orderInfo })
    }
    .cardContainer()
  }

  @Builder
  FormCard3() {
    Column() {
      FormItem({
        param: {
          type: FormType.TEXT,
          label: '备注',
          last: true,
        },
        value: this.orderInfo.remark,
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: 10, right: 10 })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }
}
