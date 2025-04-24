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

import { CommonConstants, TypeGood } from '../common/Constant';
import { PopViewUtils } from '../common/PopViewUtils';
import { CommonUtils } from '../common/Utils';
import { GoodInfo } from '../model/ObserveModel';
import { DialogCallBuilder, PhoneParams } from './DialogCall';
import { RouterMap, RouterModule } from '../router/RouterModule';

export enum GoodCardSize {
  NORMAL,
  SMALL,
}

interface IGoodCardParam {
  titleFg: number;
  titleWeight: number;
  showSubTitle: boolean;
  showBtn: boolean;
  symbolFg: number;
  vipPriceFg: number;
  vipPriceWeight: number;
  textConsultFg: number;
  imgAspectRatio: number;
}

const STYLE_GOOD_NORMAL: IGoodCardParam = {
  titleFg: 14,
  titleWeight: 500,
  showSubTitle: true,
  showBtn: true,
  symbolFg: 12,
  vipPriceFg: 20,
  vipPriceWeight: 500,
  textConsultFg: 14,
  imgAspectRatio: 2,
};

const STYLE_GOOD_SMALL: IGoodCardParam = {
  titleFg: 12,
  titleWeight: 400,
  showSubTitle: false,
  showBtn: false,
  symbolFg: 10,
  vipPriceFg: 14,
  vipPriceWeight: 500,
  textConsultFg: 12,
  imgAspectRatio: 1,
};

@ComponentV2
export struct GoodCard {
  @Param goodInfo: GoodInfo = new GoodInfo();
  @Param type: GoodCardSize = GoodCardSize.NORMAL;
  @Param hotline: string = '';
  @Local styleGood: IGoodCardParam = STYLE_GOOD_NORMAL;

  aboutToAppear(): void {
    if (this.type === GoodCardSize.SMALL) {
      this.styleGood = STYLE_GOOD_SMALL;
    }
  }

  @Computed
  get isTypePay() {
    return this.goodInfo.type === TypeGood.PAY;
  }

  build() {
    Column() {
      Image(CommonUtils.handleImgUrl(this.goodInfo.image))
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(this.styleGood.imgAspectRatio)
        .alt($r('app.media.ic_placeholder_img'))

      Column({ space: 10 }) {
        Text(this.goodInfo.title)
          .fontSize(this.styleGood.titleFg)
          .fontWeight(this.styleGood.titleWeight)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)

        if (this.styleGood.showSubTitle) {
          Text(this.goodInfo.subTitle)
            .fontSize(14)
            .fontColor($r('app.color.common_grey'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }

        Row({ space: 6 }) {
          if (this.isTypePay) {
            Text() {
              Span('￥').fontSize(this.styleGood.symbolFg)
              Span(CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(this.styleGood.vipPriceFg)
            }
            .fontWeight(this.styleGood.vipPriceWeight)
            .fontColor($r('app.color.common_red'))
          } else {
            Text('咨询报价')
              .fontSize(this.styleGood.textConsultFg)
              .fontWeight(this.styleGood.vipPriceWeight)
              .fontColor($r('app.color.common_red'))
          }

          Blank()
          if (this.styleGood.showBtn) {
            Button() {
              Text(this.isTypePay ? $r('app.string.good_card_appoint_btn') : '咨询')
                .fontSize(14)
                .fontWeight(500)
                .fontColor(Color.White)
                .width(56)
                .height(20)
                .textAlign(TextAlign.Center)
            }
            .backgroundColor($r('app.color.common_theme_color'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .onClick(() => {
              if (this.isTypePay) {
                RouterModule.push({ url: RouterMap.ORDER_PAGE, param: this.goodInfo });
              } else {
                PopViewUtils.showPopView<PhoneParams>(wrapBuilder(DialogCallBuilder),
                  new PhoneParams(this.hotline.split(',')),
                  { alignment: DialogAlignment.Bottom, autoCancel: true });
              }
            })
          }
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .padding(10)
    }
    .width(CommonConstants.FULL_PERCENT)
    .clip(true)
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(8)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: this.goodInfo });
    })
  }
}
