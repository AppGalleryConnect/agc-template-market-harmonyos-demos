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
import { AppStorageV2 } from '@kit.ArkUI';
import {
  CommonUtils,
  GoodCardSize,
  GoodInfo,
  IGoodCardParam,
  STYLE_GOOD_NORMAL,
  STYLE_GOOD_SMALL,
  TypeGood,
  WindowUtil
} from 'module_base';
import { LoginBtnInCard } from '../login/LoginUtil';
import { LinkState } from '../model/ObserveModel';

@ComponentV2
export struct ServiceCard {
  @Param isService: boolean = false;
  @Param goodInfo: GoodInfo = new GoodInfo();
  @Param type: GoodCardSize = GoodCardSize.NORMAL;
  @Local styleGood: IGoodCardParam = STYLE_GOOD_NORMAL;
  linkState: LinkState = AppStorageV2.connect(LinkState, () => new LinkState())!;

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
    Row({ space: 12 }) {
      Image(CommonUtils.handleImgUrl(this.goodInfo.image))
        .borderRadius(16)
        .width(88)
        .height(88)
        .alt($r('app.media.ic_placeholder_img'))

      Column() {

        Text(this.goodInfo.title)
          .fontSize(this.styleGood.titleFg)
          .fontWeight(this.styleGood.titleWeight)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .lineHeight(19)

        if (this.styleGood.showSubTitle) {
          Text(this.goodInfo.subTitle)
            .lineHeight(19)
            .fontSize(14)
            .fontColor($r('app.color.common_grey'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .margin({ top: 6 })
        }

        Blank()

        Row() {
          if (this.isTypePay) {
            Text() {
              Span('￥').fontSize(this.styleGood.symbolFg)
              Span(CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(this.styleGood.vipPriceFg)
            }
            .fontWeight(this.styleGood.vipPriceWeight)
            .fontColor($r('sys.color.multi_color_08'))
          } else {
            Text('咨询报价')
              .fontSize(this.styleGood.textConsultFg)
              .fontWeight(this.styleGood.vipPriceWeight)
              .fontColor($r('sys.color.multi_color_08'))
          }

          if (this.styleGood.showBtn) {
            if (this.linkState.isLink) {
              Button(this.isTypePay ? $r('app.string.good_card_appoint_btn') : $r('app.string.good_card_consult_btn'),
                { type: ButtonType.Capsule, controlSize: ControlSize.SMALL })
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(500)
                .fontColor($r('sys.color.font_on_primary'))
                .backgroundColor($r('app.color.common_theme_color'))
                .width(76)
                .onClick(() => {
                  this.onBtnClick();
                })
            } else {
              if (this.isTypePay) {
                LoginBtnInCard({
                  onBind: this.onBtnClick
                })
              } else {
                Button($r('app.string.good_card_consult_btn'),
                  { type: ButtonType.Capsule, controlSize: ControlSize.SMALL })
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('app.color.common_theme_color'))
                  .width(76)
                  .onClick(() => {
                    this.onBtnClick();
                  })
              }
            }

          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .height(112)
    .padding(12)
    .width('100%')
    .clip(true)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .onClick(() => {
      this.onCardClick();
    })
  }
}
