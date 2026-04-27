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

import { GoodCardSize, IGoodCardParam, STYLE_GOOD_NORMAL, STYLE_GOOD_SMALL, TypeGood } from '../common/Constant';
import { GoodInfo } from '../common/ObserveModel';
import { CommonUtils } from '../common/CommonUtils';
import { WindowUtil } from '../common/WindowUtils';

@ComponentV2
export struct GoodCard {
  @Param goodInfo: GoodInfo = new GoodInfo();
  @Param type: GoodCardSize = GoodCardSize.NORMAL;
  @Local styleGood: IGoodCardParam = STYLE_GOOD_NORMAL;

  @Computed
  get isTypePay() {
    return this.goodInfo.type === TypeGood.PAY;
  }

  @Event onBtnClick: () => void = () => {
  };

  @Event onCardClick: () => void = () => {
  };

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    if (this.type === GoodCardSize.SMALL) {
      this.styleGood = STYLE_GOOD_SMALL;
    }
  }

  build() {
    Column() {
      Image(CommonUtils.handleImgUrl(this.goodInfo.image))
        .width('100%')
        .aspectRatio(this.styleGood.imgAspectRatio)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.ic_placeholder_img'))

      Column({ space: 4 }) {
        Text(this.goodInfo.title)
          .fontSize(this.styleGood.titleFg)
          .fontWeight(this.styleGood.titleWeight)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)

        if (this.isTypePay) {
          Text() {
            Span('￥').fontSize(this.styleGood.symbolFg)
            Span(CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(this.styleGood.vipPriceFg)
            Span(this.goodInfo.serviceDetailList?.length ? '起' : '').fontSize(this.styleGood.symbolFg)
          }
          .fontWeight(this.styleGood.vipPriceWeight)
          .fontColor($r('sys.color.multi_color_08'))
        } else {
          Text('咨询报价')
            .fontSize(this.styleGood.textConsultFg)
            .fontWeight(this.styleGood.vipPriceWeight)
            .fontColor($r('sys.color.multi_color_08'))
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: 8,
        bottom: 8,
        left: 12,
        right: 12
      })
    }
    .width('100%')
    .clip(true)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(16)
    .onClick(() => {
      this.onCardClick();
    })
  }
}
