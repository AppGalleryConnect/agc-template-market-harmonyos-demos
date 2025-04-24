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
  CardContainer,
  CommonConstants,
  CommonUtils,
  DialogCallBuilder,
  GoodInfo,
  HomeBaseInfo,
  IContent,
  IntroItem,
  IntroType,
  IQuestionAnswer,
  PhoneParams,
  PopViewUtils,
  RouterMap,
  RouterModule,
  TypeGood,
  UIEmpty,
} from 'utils'
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';

@Builder
export function GoodDetailBuilder() {
  GoodDetail()
}

@ComponentV2
export struct GoodDetail {
  @Local good: GoodInfo = new GoodInfo();
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;

  aboutToAppear(): void {
    const params: GoodInfo[] = RouterModule.getNavParam({ url: RouterMap.GOOD_DETAIL });
    if (params.length && params[params.length - 1]) {
      const param = params[params.length - 1];
      this.good = param;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            this.Banner()
            Column({ space: 10 }) {
              this.TitleCard()
              if (this.good.serviceContentList) {
                this.ServiceContentCard()
              }
              if (this.good.servicePipeList) {
                this.ServiceWorkflowCard()
              }
              if (this.good.feeList) {
                this.ChargeInstructionCard()
              }
              if (this.good.qaList.length) {
                this.CommonQuestionCard()
              }
            }
            .padding({
              left: 10,
              right: 10,
              top: 6,
              bottom: 6,
            })

            this.MoreDetail()
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        this.BottomOperate()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title(this.good.title || '服务详情', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  Banner() {
    Image(CommonUtils.handleImgUrl(this.good.image))
      .width(CommonConstants.FULL_PERCENT)
  }

  @Computed
  get priceLabel() {
    return CommonUtils.handleCash(this.good.vipPrice);
  }

  @Builder
  TitleCard() {
    Column({ space: 10 }) {
      Row() {
        if (this.good.type === TypeGood.PAY) {
          Text() {
            Span('￥').fontSize(12)
            Span(this.priceLabel).fontSize(20)
            Span(this.good.serviceDetailList?.length ? '起' : '').fontSize(12)
          }
          .fontColor($r('app.color.common_red'))
          .fontWeight(500)
        } else {
          Text('咨询报价')
            .fontColor($r('app.color.common_red'))
            .fontSize(20)
            .fontWeight(500)
        }
        Blank()
        Text(`年售${this.good.soldNum}+`).fontSize(12).fontColor($r('app.color.common_grey'))
      }
      .width(CommonConstants.FULL_PERCENT)

      Text(this.good.title).fontSize(16).fontWeight(500)
      Row() {
        Text(this.good.subTitle).fontSize(12).fontColor($r('app.color.common_grey'))
        Blank()
        Row({ space: 6 }) {
          Image($r('app.media.ic_call_store')).width(16).height(16)
          Text('联系商家').fontSize(10)
        }
        .onClick(() => {
          PopViewUtils.showPopView<PhoneParams>(wrapBuilder(DialogCallBuilder),
            new PhoneParams(this.homeBaseInfo.hotline.split(',')),
            { alignment: DialogAlignment.Bottom, autoCancel: true });
        })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ServiceContentCard() {
    CardContainer({ title: '服务内容' }) {
      Column({ space: 10 }) {
        ForEach(this.good.serviceContentList, (v: IContent) => {
          Column({ space: 2 }) {
            Text(v.title).fontSize(12).fontWeight(500)
            Text(v.content).fontSize(12)
          }
          .width(CommonConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
        }, (v: IContent) => v.title + v.content)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ServiceWorkflowCard() {
    CardContainer({ title: '服务流程' }) {
      Column({ space: 10 }) {
        ForEach(this.good.servicePipeList, (v: string) => {
          Text(v).fontSize(12)
        }, (v: string) => v)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ChargeInstructionCard() {
    CardContainer({ title: '费用说明' }) {
      Column({ space: 10 }) {
        ForEach(this.good.feeList, (v: string) => {
          Text(v).fontSize(12)
        }, (v: string) => v)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  CommonQuestionCard() {
    CardContainer({ title: '常见问题' }) {
      Column({ space: 10 }) {
        ForEach(this.good.qaList, (v: IQuestionAnswer) => {
          Column({ space: 6 }) {
            Row({ space: 6 }) {
              Image($r('app.media.ic_question')).width(16).height(16).objectFit(ImageFit.Contain)
              Text(v.question).fontSize(12).fontWeight(500)
            }

            Text(v.answer).fontSize(12).margin({ left: 24 })
          }
          .alignItems(HorizontalAlign.Start)
        }, (v: IQuestionAnswer) => v.question + v.answer)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  MoreDetail() {
    Text('—— 图文详情 ——').fontSize(12).fontColor($r('app.color.common_grey'))
    if (this.good.intro.length) {
      Column({ space: 8 }) {
        ForEach(this.good.intro, (item: IntroItem) => {
          if (item.type === IntroType.IMAGE) {
            Image(CommonUtils.handleImgUrl(item.value)).width(CommonConstants.FULL_PERCENT).height('auto')
          }
          if (item.type === IntroType.TEXT) {
            Text(item.value).fontSize(14)
          }
        }, (item: IntroItem) => item.type + item.value)
      }
      .padding({ bottom: 10 })
    } else {
      UIEmpty({ emptyDesc: '暂无图文详情', fg: 12 }).margin({ top: 60, bottom: 60 })
    }
  }

  @Computed
  get submitBtnLabel() {
    return this.good.type === TypeGood.PAY ? '立即预约' : '咨询报价';
  }

  onSubmit() {
    if (this.good.type === TypeGood.PAY) {
      RouterModule.push({ url: RouterMap.ORDER_PAGE, param: this.good });
    } else {
      PopViewUtils.showPopView<PhoneParams>(wrapBuilder(DialogCallBuilder),
        new PhoneParams(this.homeBaseInfo.hotline.split(',')),
        { alignment: DialogAlignment.Bottom, autoCancel: true });
    }
  }

  @Builder
  BottomOperate() {
    Row() {
      Button(this.submitBtnLabel)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(500)
        .width(CommonConstants.FULL_PERCENT)
        .height(40)
        .backgroundColor($r('app.color.common_theme_color'))
        .onClick(() => {
          this.onSubmit();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
