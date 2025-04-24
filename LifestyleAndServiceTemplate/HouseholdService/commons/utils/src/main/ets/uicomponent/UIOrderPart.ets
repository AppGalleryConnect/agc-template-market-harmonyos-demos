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

import { CommonConstants, OrderStatus } from '../common/Constant';
import { CommonUtils } from '../common/Utils'
import { FullOrderInfo, SimpleGoodInfo } from '../model/ObserveModel'

@ComponentV2
export struct UIOrderPart {
  @Param simpleGoodInfo: SimpleGoodInfo = new SimpleGoodInfo();
  @Param simpleOrderInfo: FullOrderInfo = new FullOrderInfo();
  @Param isFromMine: boolean = false;

  @Computed
  get isToPay() {
    return this.simpleOrderInfo.status === OrderStatus.TO_PAY;
  }

  @Computed
  get goodPrice() {
    if (this.isFromMine) {
      return CommonUtils.handleCash(this.simpleOrderInfo.actualPay);
    }
    return CommonUtils.handleCash(this.simpleGoodInfo.vipPrice || this.simpleOrderInfo.vipPrice);
  }

  @Computed
  get actualPayLabel() {
    return CommonUtils.handleCash(this.simpleOrderInfo.actualPay || this.simpleGoodInfo.vipPrice);
  }

  build() {
    Row({ space: 8 }) {
      Image(CommonUtils.handleImgUrl(this.simpleGoodInfo.image || this.simpleOrderInfo.image))
        .width(86)
        .aspectRatio(1)
        .borderRadius(8)
      Column() {
        Text(this.simpleGoodInfo.title || this.simpleOrderInfo.title)
          .fontSize(16)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
        Text(this.simpleGoodInfo.subTitle || this.simpleOrderInfo.subTitle)
          .fontSize(12)
          .fontWeight(400)
          .fontColor($r('app.color.common_grey'))
          .margin({ top: 8 })
        Blank()
        Row() {
          Text() {
            Span('￥').fontSize(10)
            Span(this.goodPrice).fontSize(14)
          }
          .fontColor(Color.Black)
          .fontWeight(500)

          Blank()
          if (!this.isFromMine) {
            Text() {
              Span('实付款 ').fontSize(12)
              Span('￥').fontSize(10)
              Span(this.actualPayLabel).fontSize(12)
            }
            .fontColor(Color.Black)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .layoutWeight(1)
      .height(86)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
  }
}
