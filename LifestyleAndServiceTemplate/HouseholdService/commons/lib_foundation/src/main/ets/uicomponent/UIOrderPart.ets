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
import { CommonUtils, WindowUtil } from 'module_base';
import { CommonConstants, OrderStatus } from '../common/Constant';
import { FullOrderInfo, SimpleGoodInfo } from '../model/ObserveModel';

@ComponentV2
export struct UIOrderPart {
  @Param simpleGoodInfo: SimpleGoodInfo = new SimpleGoodInfo();
  @Param simpleOrderInfo: FullOrderInfo = new FullOrderInfo();

  @Computed
  get isToPay() {
    return this.simpleOrderInfo.status === OrderStatus.TO_PAY;
  }

  @Computed
  get actualPayLabel() {
    return CommonUtils.handleCash(this.simpleOrderInfo.actualPay || this.simpleGoodInfo.vipPrice);
  }

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
  }

  build() {
    Row({ space: 12 }) {
      Image(CommonUtils.handleImgUrl(this.simpleGoodInfo.image || this.simpleOrderInfo.image))
        .width(80)
        .aspectRatio(1)
        .borderRadius(8)
      Column() {
        Text(this.simpleGoodInfo.title || this.simpleOrderInfo.title)
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(21)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.simpleGoodInfo.subTitle || this.simpleOrderInfo.subTitle)
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(16)
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ top: 4 })
        Blank()
        Row() {
          Text() {
            Span(this.actualPayLabel)
            Span('元')
          }
          .fontWeight(500)
          .fontColor($r('sys.color.multi_color_08'))
          .fontSize(16)
        }
        .justifyContent(FlexAlign.End)
        .width(CommonConstants.FULL_PERCENT)
      }
      .layoutWeight(1)
      .height(80)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
  }
}
